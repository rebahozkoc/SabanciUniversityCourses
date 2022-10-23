#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>


#ifdef linux
#include <semaphore.h>
#elif __APPLE__
#include "zemaphore.h"
#endif

sem_t * A;
sem_t * B;
sem_t general;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_barrier_t barrier; // the barrier synchronization object

int * a_count;
int * b_count;


void *create_supporter(void *arg) {
    int* team = (int *) arg;
    int is_captain = 0;
    // temp count values and semaphores 
    int * team_count;
    int * other_count;
    sem_t * temp_sem;
    sem_t * other_sem;

    // Don't let more than 5 threads to reach this code synchroniously
    sem_wait(&general);
    printf("Thread ID: %ld, Team: %c, I am looking for a car\n", pthread_self(), * team);
    if (*team == 'A'){
        team_count = a_count;
        other_count = b_count;
        temp_sem = A;
        other_sem = B;
    }else{
        team_count = b_count;
        other_count = a_count;
        temp_sem = B;
        other_sem = A;
    }

    pthread_mutex_lock(&mutex);
    *team_count = *team_count + 1;
    // If AA - BB form happened
    if(*team_count == 2 && *other_count >= 2){
        is_captain = 1;
        *team_count = 0;
        *other_count -= 2;
        // Let one more A passenger and 2 B passengers to get in the car
        sem_post(&(*temp_sem));
        sem_post(&(*other_sem));
        sem_post(&(*other_sem));
        pthread_mutex_unlock(&mutex);
    // If AAAA form happened
    }else if (*team_count == 4){
        *team_count = 0;
        // Let three more A passenger to get in the car
        sem_post(&(*temp_sem));
        sem_post(&(*temp_sem));
        sem_post(&(*temp_sem));
        is_captain = 1;
        pthread_mutex_unlock(&mutex);
    }else{
        pthread_mutex_unlock(&mutex);
        // Wait until the correct form happens (captain does not wait here)
        sem_wait(&(*temp_sem));
    }

    printf("Thread ID: %ld, Team: %c, I have found a spot in a car\n",  pthread_self(), * team);
    // Wait until every passenger to get in the car
    pthread_barrier_wait (&barrier);
    if (is_captain){
        printf("Thread ID: %ld, Team: %c, I am the captain and driving the car\n",  pthread_self(), * team);
    }
    sem_post(&general);
    
    return NULL;
}


int main(int argc, char *argv[]){
    int numberA = atoi(argv[1]);
    int numberB = atoi(argv[2]);
    
    a_count = malloc(sizeof(int));
    b_count = malloc(sizeof(int));
    * a_count = 0;
    * b_count = 0;

    A = malloc(sizeof(sem_t)); 
    B = malloc(sizeof(sem_t));

    pthread_barrier_init (&barrier, NULL, 4);
    // Check input
    if ((numberA % 2 == 0) && (numberB % 2 == 0) && ((numberA + numberB) % 4 == 0)){
        pthread_t* threads_A = (pthread_t*) malloc(numberA * sizeof(pthread_t));
        pthread_t* threads_B = (pthread_t*) malloc(numberB * sizeof(pthread_t));
        int i;
        int teamNameA = 'A';
        int teamNameB = 'B';

        sem_init(&(*A), 0, 0);
        sem_init(&(*B), 0, 0);  
        sem_init(&general, 0, 5);

        // Create threads
        for (i = 0; i < numberA; i++){
            pthread_create(&(threads_A[i]), NULL, create_supporter, &teamNameA);
        }
        
        for (i = 0; i < numberB; i++){
            pthread_create(&(threads_B[i]), NULL, create_supporter, &teamNameB);
        }

        // Wait threads to finish
        for (i = 0; i < numberA; i++){
            pthread_join(threads_A[i], NULL);
        }
        for (i = 0; i < numberB; i++){
            pthread_join(threads_B[i], NULL);
        }

    }
        
    printf("The main terminates\n");


}