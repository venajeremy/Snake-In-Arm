#include <stdio.h>
#include <stdlib.h>
//#include <ncurses.h> uncomment for ncurses
#include <unistd.h>
#include <time.h>

typedef struct snakeP{ 
    int xpos;
    int ypos;
    struct snakeP *forward;
    struct snakeP *backward;
} snakePart;

snakePart* createNewHead(){
    return (snakePart*) malloc(sizeof(snakePart));
}

// Stay in C
int getInput(){
    int input;
    input = getchar();
    while(getchar() != '\n');
    return input;

    /* uncomment for ncurses
    int input = getch();
    while(getch()!=ERR){
    }
    return input;
    */
}

// Stay in C
void printBoard(int boardWidth, int boardHeight, char **graph){

    for(int i = 0 ; i < boardHeight ; i++){
        for(int j = 0 ; j < boardWidth ; j++){
            printf(" %c", graph[i][j]);
        }
        printf("\n\r");
        printf("\n\r");
    }

}

int getRand(){
    return rand();
}

// Assembly
void placeFood(int boardWidth, int boardHeight, char **graph, int *key, int *hand, int snakeSize){

    // Get a valid position to place our food ( -snakeSize are all the positions of the snake )
    int position = getRand() % ((boardWidth * boardHeight)-snakeSize);

    // Get y and x position from position
    int y = hand[position] / boardWidth;
    int x = hand[position] % boardWidth;

    graph[y][x]='@';
    
    return;
}

// Assembly
void swapKeyValues(int *key, int *hand, int pos1, int pos2){
   int location1 = key[pos1];
   int location2 = key[pos2];
   hand[location1] = pos2;
   hand[location2] = pos1;
   key[pos1] = location2;
   key[pos2] = location1;
   return;
}

// Stay in C
void initializeMap(char ***map, int height, int width){

    *map = (char**) malloc(sizeof(char*) * height);   // Allocate rows of 2d Array

    for(int i = 0 ; i < height ;  i++){
        (*map)[i] = (char*) malloc(sizeof(char) * width);      // Allocate all columns of 2d Array
        for(int j = 0 ; j < width ;  j++){
            (*map)[i][j] = ' ';                                // Initialize values of 2d Array
        }   
    }

}

// Assembly
void placeBoarder(char ***map, int height, int width){
    for(int i = 0 ; i < width ; i++){
        (*map)[0][i]='-';
        (*map)[height-1][i]='-';
    }
    
    for(int i = 0 ; i < height ; i++){
        (*map)[i][0]='|';
        (*map)[i][width-1]='|';
    }
}

// Stay in C
void initializeKeyAndHand(int **key, int **hand, int width, int height){
    // Initialize arrays for placing food
    (*key) = (int*) malloc(sizeof(int) * width * height);     // Used to hold the location of a food position in the hand

    (*hand) = (int*) malloc(sizeof(int) * width * height);    // Used to hold food positions avaiable to pick randomly
    
    // Initialize every food position at its index
    for(int i = 0 ; i < width*height ; i++){
        (*key)[i] = i;
        (*hand)[i] = i;
    }
}

// Assembly
void cleanUp(snakePart **head, char ***map, int height, int **hand, int **key){ 

    //endwin(); // Clean up ncurses // uncomment for ncurses
    
    // Delete snake
    snakePart *tempPart=*head;
    snakePart *next=tempPart->backward;
    while(next!=NULL){
        free(tempPart);
        tempPart=next;
        next=next->backward;
    }
    free(tempPart);

    // Delete map
    for(int i = 0 ; i < height ; i++){
        free((*map)[i]);
    }
    free(*map);

    // Delete key and hand
    free(*key);
    free(*hand);

    printf("\n");

    return;
}

void startGame(int height, int width){

    printf("Loading Game...\n");

    //initscr(); // Initialize ncurses // uncomment for ncurses
    //timeout(0); // uncomment for ncurses
    srand(time(NULL));  // Initialize random number generator


    // ------------------ Initialize The Map ------------------- // 
    char **map = NULL;
    initializeMap(&map, height, width);  // initializeMap makes map point to a 2d array allocated with sizes height and width
    placeBoarder(&map, height, width); // place the boarder around the map

    // ------------------ Initialize Components for Placeing Food ------------------- // 

    int *key = NULL;
    int *hand = NULL;
    initializeKeyAndHand(&key, &hand, width, height);

    // ---------------------- Initialize Snake ----------------------- //

    // Right now there is a hardcoded snake start size of 3

    int snakeSize=0;

    snakePart *tail = createNewHead();
    snakePart *head = createNewHead();
    snakePart *body = createNewHead();

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
        snakeSize++;    // Increase the snake size
        swapKeyValues(key, hand, (tempPart->ypos*width)+tempPart->xpos, width*height-snakeSize);  // Add new part to correct postion of key and hand
        map[tempPart->ypos][tempPart->xpos]='#';    // Paint the snake character onto the map
        tempPart=tempPart->backward;
    }


    // Place the first food on the map
    placeFood(width, height, map, key, hand, snakeSize); 
    
    // Create variables for game loop
    snakePart *moveHead;    // Holds the forward moving head
    int ch;     // Stores new input
    int currentDirection='d';   // Store current input

    // Game loop
    char running=1;

    // Start Game Loop
    while(running==1){

        // Clear previous board
        /* uncomment for ncurses (delete above clear method)
        clear(); 
        refresh();
        */
        

        // Create new Head
        moveHead = createNewHead();
        head->forward=moveHead;
        moveHead->backward=head;
        moveHead->xpos=head->xpos;
        moveHead->ypos=head->ypos;
        
        // Get input
        ch = getInput();

        system("clear");    // delete if using ncurses

        // No input entered check
        if(ch=='a'||ch=='d'||ch=='w'||ch=='s'||ch=='q'){
            currentDirection = ch;
        }
        /* uncomment for ncurses and delete above
        if(ch!=ERR){
        currentDirection = ch;
        }
        */

        // Move in inputed direction
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
        
        // Quit game if q is pressed
        if(currentDirection=='q'){
            running=0;
        }
 
        // Set the heap of the linked list to the new head we allocated
        head=moveHead;

        // If eating
        if(map[head->ypos][head->xpos]=='@'){
            
            // Swap new head with length-snakeSize
            int pos1 = (head->ypos*width) + head->xpos;
            int pos2 = hand[(width*height)-snakeSize];
            swapKeyValues(key, hand, pos1, pos2);
            snakeSize++;

            // Dont remove tail
            map[head->ypos][head->xpos] = '#';

            placeFood(width, height, map, key, hand, snakeSize);
        } else {

            // Swap old tail and new head in hand (for placing food not on snake)
            int pos1 = (head->ypos*width) + head->xpos;
            int pos2 = (tail->ypos*width) + tail->xpos;
            swapKeyValues(key, hand, pos1, pos2);

            // Remove tail
            map[head->ypos][head->xpos] = '#';
            map[tail->ypos][tail->xpos] = ' ';
            tail=tail->forward;
            free(tail->backward);   // Free tail memory
            tail->backward=NULL;
        }

        // Print board to screen
        printBoard(width, height, map);

        // Wait a tick
        usleep(250000);
    }


    // ---------------------------- Cleanup ----------------------------- //
    
    cleanUp(&head, &map, height, &hand, &key);

}
