//compile with nvcc mat_mult2.cu  -Xcompiler -fopenmp -O3 -Xcompiler -O3

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "common.h"
#include <stdio.h>
#include <math.h>
#include "omp.h"

#define THREADS_PER_BLOCK 1024
#define TILE_WIDTH 32

void matrixMultiplyCPU(float *a, float *b, float *c, int width) {
  float result;

  for (int row = 0; row < width; row++) {
    for (int col = 0; col < width; col++) {
      result = 0;
      for (int k = 0; k < width; k++) {
        result += a[row * width + k] * b[k * width + col];
      }
      c[row * width + col] = result;
    }
  }
}

void matrixMultiplyCPU_Opt(const float * __restrict a, const float * __restrict__ b, float * __restrict__ c, float * __restrict__ tb, int width, int nt) {
  float result;
  
  //transpose b
  for (int row = 0; row < width; row++) {
    for (int col = 0; col < width; col++) {
      tb[col * width + row] = b[row * width + col];
    }
  }

#pragma omp parallel for num_threads(nt) schedule(static)
  for (int row = 0; row < width; row++) {
    float* crow = c + row * width;
    const float* arow = a + row * width;
    for (int col = 0; col < width; col++) {
      result = 0;
       const float* bcol = tb + col * width; 
       for (int k = 0; k < width; k+=8) {
        result += arow[k] * bcol[k];
        result += arow[k+1] * bcol[k+1];
        result += arow[k+2] * bcol[k+2];
        result += arow[k+3] * bcol[k+3];
	result += arow[k+4] * bcol[k+4];
        result += arow[k+5] * bcol[k+5];
        result += arow[k+6] * bcol[k+6];
        result += arow[k+7] * bcol[k+7];

      }
      crow[col] = result;
    }
  }
}

__global__ void matrixMultiplySimple(float *a, float *b, float *c, int width) {
  int col = threadIdx.x + blockIdx.x * blockDim.x;
  int row = threadIdx.y + blockIdx.y * blockDim.y;

  float result = 0;

  if (col < width && row < width) {
    for (int k = 0; k < width; k++) {
      result += a[row * width + k] * b[k * width + col];
    }
    c[row * width + col] = result;
  }
}


//check if this is faster than the version above. why?
__global__ void matrixMultiplyOptimised(float *a, float *b, float *c, int width) {
  // Allocate 2D tiles in shared memory
  __shared__ float s_a[TILE_WIDTH][TILE_WIDTH];
  __shared__ float s_b[TILE_WIDTH][TILE_WIDTH];

  // Calculate row and column index of element
  int row = blockIdx.y * blockDim.y + threadIdx.y; 
  int col = blockIdx.x * blockDim.x + threadIdx.x;

  float result = 0;
  
  // Loop over tiles of input in phases
  for (int p = 0; p < width / TILE_WIDTH; p++) {
    // Collaboratively load tiles into shared memory
    s_a[threadIdx.x][threadIdx.y] = a[row * width + (p * TILE_WIDTH + threadIdx.x)];
    s_b[threadIdx.x][threadIdx.y] = b[col + width * (p * TILE_WIDTH + threadIdx.y)];

    __syncthreads();     // Wait until all data is loaded before allowing any threads in the block to continue

    // Dot product between row of s_a and column of s_b
    for (int i = 0; i < TILE_WIDTH; i++) {
      result += s_a[i][threadIdx.y] * s_b[threadIdx.x][i];
    }

    __syncthreads();    // Wait until all calculations are finished before allowing any threads in the block to continue
  }

  // Write result
  c[row * width + col] = result;
}

int main() {
  int width = 2048; // Define width of square matrix
  int sqrtThreads = sqrt(THREADS_PER_BLOCK);
  int nBlocks = width / sqrtThreads;
  if (width % sqrtThreads != 0) { // Add an extra block if necessary
    nBlocks++;
  }
  dim3 grid(nBlocks, nBlocks, 1);
  dim3 block(sqrtThreads, sqrtThreads, 1); // Max number of threads per block

  cudaSetDevice(0);

  // Initialise host pointers (dynamically allocated memory) and device pointers
  float *a_h;
  float *b_h;
  float *c_h; // GPU results
  float *d_h; // CPU results
  float *a_d;
  float *b_d;
  float *c_d;

  int size; // Number of bytes required by arrays

  // Create timer
  cudaEvent_t start;
  cudaEvent_t stop;
  float elapsed1, elapsed2, elapsed3;

  // Print out information about blocks and threads
  printf("Number of threads: %i (%ix%i)\n", block.x*block.y, block.x, block.y);
  printf("Number of blocks: %i (%ix%i)\n\n", grid.x*grid.y, grid.x, grid.y);

  // Dynamically allocate host memory
  size = width * width * sizeof(float);
  
  a_h = (float*) malloc(size);
  b_h = (float*) malloc(size);
  float * tb = (float*) malloc(size);
  c_h = (float*) malloc(size);
  d_h = (float*) malloc(size);

  // Load host arrays with data
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < width; j++) {
      a_h[i * width + j] = i + 1.0;
      b_h[i * width + j] = j + 2.0;
      c_h[i * width + j] = 0;
    }
  }

  // Allocate device memory
  cudaCheck(cudaMalloc((void**)&a_d, size));
  cudaCheck(cudaMalloc((void**)&b_d, size));
  cudaCheck(cudaMalloc((void**)&c_d, size));

  // Copy host memory to device memory
  cudaCheck(cudaMemcpy(a_d, a_h, size, cudaMemcpyHostToDevice));
  cudaCheck(cudaMemcpy(b_d, b_h, size, cudaMemcpyHostToDevice));
  cudaCheck(cudaMemcpy(c_d, c_h, size, cudaMemcpyHostToDevice));

  //Create events
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  
  // Start timer for CPU
  cudaEventRecord(start, 0);
  matrixMultiplyCPU(a_h, b_h, d_h, width);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed2, start, stop);
  printf("Time to calculate results on CPU: %f ms -- result[10] = %f -- result[1000] = %f\n", elapsed2, d_h[10], d_h[1000]);
      
  // Start timer for CPU Opt
  memset(d_h, 0, size);
  cudaEventRecord(start, 0);
  matrixMultiplyCPU_Opt(a_h, b_h, d_h, tb, width, 1);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed2, start, stop);
  printf("Time to calculate results on CPU_Opt (single thread): %f ms  -- result[10] = %f -- result[1000] = %f\n", elapsed2, d_h[10], d_h[1000]);

  // Start timer for CPU Opt parallel
  memset(d_h, 0, size);
  cudaEventRecord(start, 0);
  matrixMultiplyCPU_Opt(a_h, b_h, d_h, tb, width, 8);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed2, start, stop);
  printf("Time to calculate results on CPU_Opt (32 threads): %f ms -- result[10] = %f -- result[1000] = %f\n\n", elapsed2, d_h[10], d_h[1000]);
  
  // Start timer for GPU
  memset(c_h, 0, size);
  cudaMemset(c_d, 0, size);
  cudaEventRecord(start, 0);
  matrixMultiplySimple<<<grid, block>>>(a_d, b_d, c_d, width);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed1, start, stop);
  cudaDeviceSynchronize();
  printf("Time to calculate results on GPU: %f ms\n", elapsed1);
  printf("Effective performance: %.3f GFlop\n", ((width/1024.0f) * (width/1024.0f) * (width/1024.0f) * 2.0) / (elapsed1 / 1000));
  printf("Effective bandwith: %.3f GB\n", ((3.0 * (width * width) * sizeof(float)) / 1000000000) / (elapsed1 / 1000));
  cudaMemcpy(c_h, c_d, size, cudaMemcpyDeviceToHost);
  printf("result[10] = %f -- result[1000] = %f\n\n", c_h[10], c_h[1000]);
    
  // Start timer for GPU (optimised)
  memset(c_h, 0, size);
  cudaMemset(c_d, 0, size);
  cudaEventRecord(start, 0);
  matrixMultiplyOptimised<<<grid, block>>>(a_d, b_d, c_d, width);
  cudaCheck(cudaPeekAtLastError());
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed3, start, stop);
  printf("Time to calculate results on GPU (optimised): %f ms\n", elapsed3);
  printf("Effective performance: %.3f GFlop\n", ((width/1024.0f) * (width/1024.0f) * (width/1024.0f) * 2.0) / (elapsed3 / 1000));
  printf("Effective bandwith: %.3f GB\n", ((3.0 * (width/1024.0f * width/1024.0f) * sizeof(float)) / 1024) / (elapsed3 / 1000));
  cudaMemcpy(c_h, c_d, size, cudaMemcpyDeviceToHost);
  printf("result[10] = %f -- result[1000] = %f\n\n", c_h[10], c_h[1000]);

  // Free memory
  free(a_h);
  free(b_h);
  free(c_h);
  free(d_h);
  cudaFree(a_d);
  cudaFree(b_d);
  cudaFree(c_d);

  cudaEventDestroy(start);
  cudaEventDestroy(stop);

  return 0;
}
