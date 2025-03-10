#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

void readInput();
void tokenise(char * arg);
void execute(char *commands[]);

char *buffer=NULL;
size_t bufsize=0;


int main() {
    while(1){
    printf("Shell> ");
    readInput();
    }
return 0;
}


void readInput(){
    getline(&buffer,&bufsize,stdin);
    buffer[strcspn(buffer,"\n")]=0;
    tokenise(buffer);
    
}

void tokenise(char * arg){
    const char delimiters[]=" ";
    int i=0,bufsize=10;
    char **args=malloc(bufsize*sizeof(char *));
    if (!args){
        perror("Memory allocation failed");
        exit(EXIT_FAILURE);
    }
    
    char *token=strtok(arg,delimiters);
    while (token!=NULL){
        args[i++]=strdup(token);
        
        if (i>=bufsize){
            bufsize+=10;
            args=realloc(args,bufsize*sizeof(char *));
            if(!args){
                perror("realloc failed");
                exit(EXIT_FAILURE);
            }
        }
        token = strtok(NULL, delimiters);
    }
    args[i]=NULL;
    execute(args);

    for (int j = 0; args[j] != NULL; j++) {
    free(args[j]);
    }
}   

void execute(char * commands[]){
    
    if (strcmp(commands[0],"exit")==0){
        printf("Exiting shell. Goodbye!");
        exit(0);
    }
    
    if (strcmp(commands[0],"cd")==0){
        if (commands[1]==NULL){
            chdir(getenv("HOME"));
        }
        else if (chdir(commands[1])!=0){
            perror("cd failed");
        }
        return;
    }
    
    pid_t pid=fork();
    if (pid==-1){
        perror("Fork call failed");
        exit(EXIT_FAILURE);
    }
    else if (pid==0){
        execvp(commands[0],commands);
        exit(EXIT_FAILURE);
    }
    else{
        waitpid(pid,NULL,0);
    }

    
}
