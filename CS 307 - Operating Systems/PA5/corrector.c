#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>

typedef struct user{
    char* name;
    char* surname;
    char* gender;
} user;

user** db;
int user_count = 1;

void database_init(){
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    fp = fopen("database.txt", "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);
    // Check the line count the create the db array
    char ch;
    while(!feof(fp)){
        ch = fgetc(fp);
        if(ch == '\n'){
            user_count++;
        }
    }
    fclose(fp);
    fp = fopen("database.txt", "r");
    db = malloc(sizeof(user) * (user_count));  // Make array of pointers to users
    int i = 0;
    while ((read = getline(&line, &len, fp)) != -1) {
        db[i] = (user*)malloc(sizeof(user)); 

        char* gn =  strtok(line, " ");
        //db[i]->gender = (char*)malloc(sizeof(char)*4);
        if (strcmp(gn, "m") == 0){
            db[i]->gender = "Mr.";
        }else{
            db[i]->gender = "Ms.";
        }

        char* nm = strtok(NULL, " ");
        db[i]->name = (char*)malloc(strlen(nm) + 1 );
        strcpy(db[i]->name, nm);

        // Remove new line char
        char* snm = strtok(NULL, " ");

        if (snm[strlen(snm)-1] == '\n'){
            db[i]->surname = (char*)malloc(strlen(snm));
            snm[strlen(snm)-1] = '\0';
            strncpy(db[i]->surname, snm, strlen(snm)-1);
        }else{
            db[i]->surname = (char*)malloc(strlen(snm) + 1);
            strncpy(db[i]->surname, snm, strlen(snm)+1);
        }

        i++;
    }
    fclose(fp);

    if (line)
        free(line);
    
}


void correction(char* fname){
    FILE * fp = fopen(fname, "r+");
    fseek(fp, 0, SEEK_END);
    int end = ftell(fp);

    int i;
    int temp;
    char* buffer;
    for (i= 0; i< end; i++){
        int j;
        for (j = 0; j < user_count; j++){
            // read the chars from i to i+(name length) 
            fseek(fp, i, SEEK_SET);
            buffer = (char*)malloc(strlen(db[j]->name) + 1);
            fread(buffer, sizeof(char), strlen(db[j]->name), fp);
            // Found the user
            if (strcmp(db[j]->name, buffer) == 0){
                fseek(fp, (i + strlen(db[j]->name) + 1), SEEK_SET);
                fputs(db[j]->surname, fp);
                fseek(fp, i-4, SEEK_SET);
                fputs(db[j]->gender, fp);
            }
            free(buffer);
        }
    } 
}

char* glue(const char *s1, const char *s2)
{
    char *r = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(r, s1);
    strcat(r, s2);
    
    return r;
}

void visit_dirs(char* path){
    DIR *dp = opendir(path);
    struct dirent *d;
    while ((d = readdir(dp)) != NULL){
        // If the file is a txt file correct it
        if (strlen(d->d_name)> 3 && strcmp(d->d_name + (strlen(d->d_name) - 4) , ".txt") == 0){            
            char * dir = glue(path, "/");
            dir = glue(dir, d->d_name);
            correction(dir);
            free(dir);

        }else{
            // If the file is not . or .. try to open it
            // If it opens visit recursively
            if (strcmp(d->d_name, ".") != 0 && strcmp(d->d_name, "..") != 0  ){
                char * dir = glue(path, "/");
                dir = glue(dir, d->d_name);
                DIR *dp2 = opendir(dir);
                if (dp2 != 0){
                    visit_dirs(dir);
                }
                closedir(dp2);
                free(dir);
            }
        }
    }
    closedir(dp);
}


int main(int argc, char *argv[]){
    database_init();

    DIR *dp = opendir(".");
    assert(dp != NULL);
    struct dirent *d;
    while ((d = readdir(dp)) != NULL){
        if (strlen(d->d_name)> 3 && strcmp(d->d_name + (strlen(d->d_name) - 4) , ".txt") == 0 && strcmp(d->d_name, "database.txt") != 0){
            correction(d->d_name);
        }else{
            // If the file is not . or .. try to open it
            // If it opens visit recursively
            if (strcmp(d->d_name, ".") != 0 && strcmp(d->d_name, "..") != 0){
                DIR *dp2 = opendir(d->d_name);
                if (dp2 != 0){
                    visit_dirs(d->d_name);
                }
                closedir(dp2);
                
            }
        }
    }

    closedir(dp);


    // Free the memory of db array
    int i;
    for (i = 0; i <user_count; i++){
        free(db[i]->name);
        free(db[i]->surname);
        free(db[i]);
    }
    free(db);

    return 0;
}
