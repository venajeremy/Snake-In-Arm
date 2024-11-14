#include <stdio.h>
#include <stdlib.h>
#include <ncurses.h>
#include <unistd.h>

int getInput(){
    int input = getch();
    while(getch()!=ERR){
    }
    return input;
}

void printBoard(int boardWidth, int boardHeight, char **graph){

    for(int i = 0 ; i < boardHeight ; i++){
        for(int j = 0 ; j < boardWidth ; j++){
            printf("%c", graph[i][j]);
        }
        printf("\n\r");
    }

}

void placeFood(int boardWidth, int boardHeight, char **graph){
    // Bad method: randomly placing food

    int x = rand() % boardWidth;
    int y = rand() % boardHeight;

    while(graph[y][x]=='#'){
        x = rand() % boardWidth;
        y = rand() % boardHeight;
    }

    graph[y][x] = '@';
    

}

typedef struct snakeP{ 
    int xpos;
    int ypos;
    struct snakeP *forward;
    struct snakeP *backward;
} snakePart;

int main(){

    initscr(); // Initialize ncurses
    timeout(0);

    const int height = 20;  // must be greater than or 6 to fit snake
    const int width = 20;   // must be greater than or 6 to fit snake

    char **map = (char**) malloc(sizeof(char*) * height);   // Allocate rows of 2d Array

    for(int i = 0 ; i < height ;  i++){
        map[i] = (char*) malloc(sizeof(char) * width);      // Allocate all columns of 2d Array
        for(int j = 0 ; j < width ;  j++){
            map[i][j] = ' ';                                // Initialize values of 2d Array
        }   
    }

    snakePart *head = (snakePart*) malloc(sizeof(snakePart));
    snakePart *body = (snakePart*) malloc(sizeof(snakePart));
    snakePart *tail = (snakePart*) malloc(sizeof(snakePart));

    // Initialize head
    head->xpos = width/2;
    head->ypos = height/2;
    head->backward = body;

    // Initialize middle piece
    body->xpos = (width/2)-1;
    body->ypos = (height/2);
    body->forward = head;
    body->backward = tail;

    // Initialize tail
    tail->xpos = (width/2)-2;
    tail->ypos = (height/2);
    tail->forward = body;

    // Paint snake onto map
    snakePart *tempPart = head;
    while(tempPart!=NULL){
        map[tempPart->ypos][tempPart->xpos]='#';
        tempPart=tempPart->backward;
    }

    // First food
    placeFood(width, height, map); 
    
    snakePart *moveHead;    // Holds the forward moving head

    int ch;     // Stores new input
    int currentDirection='d';   // Store current input

    // Game loop
    bool running=true;
    
    while(running){

        // Clear previous board
        clear(); 
        refresh();
        

        // Create new Head
        moveHead = (snakePart*) malloc(sizeof(snakePart));
        head->forward=moveHead;
        moveHead->backward=head;
        moveHead->xpos=head->xpos;      // Should not be needed
        moveHead->ypos=head->ypos;      // Should not be needed
        
        ch = getInput();

        if(ch!=ERR){
            currentDirection = ch;
        }

        if(currentDirection=='a'){
            moveHead->xpos--;
        }
        if(currentDirection=='d'){
            moveHead->xpos++;
        }
        if(currentDirection=='w'){
            moveHead->ypos--;
        }
        if(currentDirection=='s'){
            moveHead->ypos++;
        }
        if(currentDirection=='q'){
            running=false;
        }
 
        head=moveHead;

        // If eating
        if(map[head->ypos][head->xpos]=='@'){
            // Dont remove tail
            map[head->ypos][head->xpos] = '#';
            placeFood(width, height, map);
        } else {
            // Remove
            map[head->ypos][head->xpos] = '#';
            map[tail->ypos][tail->xpos] = ' ';
            tail=tail->forward;
            free(tail->backward);   // Free tail memory
            tail->backward=NULL;
        }

        printBoard(width, height, map);

        usleep(250000);
    }


    // Game Over Clean Up:
    

    endwin(); // Clean up ncurses

    
    // Delete snake
    tempPart=head;
    snakePart *next=head->backward;
    while(next!=NULL){
        free(tempPart);
        tempPart=next;
        next=next->backward;
    }
    free(tempPart);

    // Delete map
    for(int i = 0 ; i < height ; i++){
        free(map[i]);
    }
    free(map);
    
    
    



    return 0;

    // trying to see if this is pushing code 
    // it seems like its working lol 

}
