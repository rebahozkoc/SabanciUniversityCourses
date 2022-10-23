#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
    const int ARRAY_SIZE = 11;
    char *allargs[ARRAY_SIZE];
    allargs[0] = strdup("man");  
    allargs[1] = strdup("touch");
    allargs[2] = strdup("|");
    allargs[3] = strdup("grep");
    allargs[4] = strdup("-A");
    allargs[5] = strdup("5");
    allargs[6] = strdup("-e");
    allargs[7] = strdup("--time=WORD");
    allargs[8] = strdup(">");
    allargs[9] = strdup("output.txt");
    allargs[10] = NULL;

    char *command_filename = "command.txt";

    printf("I’m SHELL process, with PID: %d - Main command is: ", (int) getpid());
    int j = 0;
    for (j = 0; j < ARRAY_SIZE-1; j++){
        printf("%s ", allargs[j]);
    }
    printf("\n");

    // Create command.txt by changing stdout to a new file descriptor
    int stdout_copy = dup(STDOUT_FILENO);
    int new_fd = open(command_filename, O_CREAT|O_WRONLY|O_TRUNC, S_IRWXU);
    dup2(new_fd, STDOUT_FILENO);
    int i;
    for (i = 0; i < ARRAY_SIZE-1; i++){
        printf("%s ", allargs[i]);
    }
    fflush(stdout);
    close(new_fd);
    
    dup2(stdout_copy, STDOUT_FILENO);

    // create grep fork
    int rc1 = fork();
    if (rc1 < 0) {
        // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc1 == 0) {
        
        // Create pipe from man to grep
        int fd2[2];
        pid_t cpid2;
        if (pipe(fd2) < 0){
            perror("pipe");
            exit(1);
        }

        // Create man fork
        int rc2 = fork();
        if (rc2 <0){
            // fork failed; exit
            fprintf(stderr, "fork failed\n");
            exit(1);
        } else if (rc2 == 0){
            char *manargs[3];
            manargs[0] = allargs[0];  
            manargs[1] = allargs[1];
            manargs[2] = NULL;
            
            printf("I’m MAN process, with PID: %d - My command is: %s %s\n", (int) getpid(), manargs[0], manargs[1]);
            close(fd2[0]);
            dup2(fd2[1], STDOUT_FILENO);
            
            execvp(manargs[0], manargs);  
        }else{
            
            int wc2 = waitpid(rc2, NULL, 0);
            close(fd2[1]);
            
            
            char *grargs[6];
            grargs[0] = allargs[3];  
            grargs[1] = allargs[4];
            grargs[2] = allargs[5];
            grargs[3] = allargs[6];
            grargs[4] = allargs[7];
            grargs[5] = NULL;
            

            printf("I’m GREP process, with PID: %d - My command is: %s %s %s %s %s\n", (int) getpid(), grargs[0], grargs[1], grargs[2], grargs[3], grargs[4]);
            // redirect man output from pipe to standard input
            dup2(fd2[0], STDIN_FILENO);
            
            // redirect grep output to output file.
            int new_fd = open(allargs[9], O_CREAT|O_WRONLY|O_TRUNC, S_IRWXU);

            dup2(new_fd, STDOUT_FILENO);
            execvp(grargs[0], grargs);
            
        }
    } else {
        // wait until grep proccess end
        int wc = waitpid(rc1, NULL, 0);
        printf("I’m SHELL process, with PID:%d - execution is completed, you can find the results in %s\n", (int) getpid(), allargs[9]);
    }
    return 0;
}
