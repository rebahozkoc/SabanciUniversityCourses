#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>


void create_table(int ** arr, int n){
    // Fills the game board with spaces.
    printf("Board size: %dx%d\n", n, n);
    int i, j;
    
    for(i = 0; i < n; i++){
        arr[i] = (int*)malloc(n * sizeof(int));
    }
    for (i = 0; i < n; i++){
        for (j = 0; j < n; j++){
            arr[i][j] = ' ';
        }
    }
}

int play_once(int ** arr, int symbol, int n, int end_status){
    // Returns 0 if the game has already ended, otherwise puts the symbol
    // at a random place in the table and returns 1
    if (end_status){
		return 0;
    }
	while(1){
		int x = rand() % n;
		int y = rand() % n;
        
		if (arr[x][y] == ' '){
			arr[x][y] = symbol;
            printf("Player %c played on: (%d,%d)\n", symbol, x, y);
			break;
        }
    }
    return 1;
}

int is_win(int ** arr, int symbol, int n){
    // returns 1 if the symbol has won 0 otherwise
    // Check horizontals
    int i, j;
    for(i = 0; i < n; i++){
        for(j = 0; j < n; j++){
            if (arr[i][j]  != symbol){
                break;
            }else if (j == n-1){
                printf("Game end\n");
                printf("Winner is %c\n", toupper(symbol));
                return 1;
            }
        }
    }
    // Check verticals
    for(i = 0; i < n; i++){
        for(j = 0; j < n; j++){
            if (arr[j][i]  != symbol){
                break;
            }else if (j == n-1){
                printf("Game end\n");
                printf("Winner is %c\n", toupper(symbol));
                return 1;
            }
        }
    }
    // Check first diagonal
    for(i = 0; i < n; i++){
        if (arr[i][i]  != symbol){
            break;
        }else if (i == n-1){
            printf("Game end\n");
            printf("Winner is %c\n", toupper(symbol));
            return 1;
        }
    }
    // Check second diagonal
    for(i = 0; i < n; i++){
        if (arr[i][n-i-1]  != symbol){
            break;
        }else if (i == n-1){
            printf("Game end\n");
            printf("Winner is %c\n", toupper(symbol));
            return 1;
        }
    }
    return 0;
}

int is_tie(int ** arr, int n){
    // returns 1 if it is tie 0 otherwise
    int i, j;
    for(i = 0; i < n; i++){
        for(j = 0; j < n; j++){
            if(arr[i][j] == ' '){
                return 0;
            }
        }
    }
    printf("Game end\n");
    printf("It is a tie\n");
    return 1;
}

void print_table(int ** arr, int n){
    // prints the table to the console
    int i, j;
    for (i = 0; i < n; i++ ){
        for (j = 0; j < n; j++){
            printf("[%c]", arr[i][j]);
        }
        printf("\n");
    }
    // Delete the allocated array
    for (i = 0; i < n; i++){
        free(arr[i]);
    }
}

struct arg_struct{
    int symbol;
    int n;
};

int end_status = 0;
int **arr;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
// turn 0 is x, turn 1 is o
int turn = 0;

void *thread_play(void *arg) {
    // Plays one time for a thread
    struct arg_struct* args = (struct arg_struct *) arg; 
    int symbol = args->symbol;
    int n = args->n;

    while(1){

        pthread_mutex_lock(&mutex);
        // Check if the thread has turn
        if((turn == 0 && symbol == 'o') || (turn == 1 && symbol == 'x')){
            pthread_mutex_unlock(&mutex);
            continue;
        }
        
        turn = (turn + 1) % 2;	
        if(play_once(arr, symbol, n, end_status)){
            if(!is_win(arr, symbol, n)){
                if(is_tie(arr, n)){
                    end_status = 1;
                    pthread_mutex_unlock(&mutex);
                    return (void *) 0;
                }
            }else{
                end_status = 1;
                pthread_mutex_unlock(&mutex);
                return (void *) 0;
            }
        }else{
            pthread_mutex_unlock(&mutex);
            return (void *) 0;
        }
        pthread_mutex_unlock(&mutex);
    }
}

int main(int argc, char *argv[]){
    srand (time(NULL));
    // Create the board
    int n = atoi(argv[1]);
    arr = (int**)malloc(n * sizeof(int*));
    create_table(arr, n);

    struct arg_struct struct_x = {'x', n};
    struct arg_struct struct_o = {'o', n};

    pthread_t thread_x, thread_o;

    if (pthread_create(&thread_x, NULL, thread_play, &struct_x) != 0){
        printf("Thread can't be created\n");
        return 1;}
    
    if (pthread_create(&thread_o, NULL, thread_play, &struct_o) != 0){
        printf("Thread can't be created\n");
        return 1;}
    
    pthread_join(thread_x, NULL); 
    pthread_join(thread_o, NULL);

    print_table(arr, n);
    return 0;
}