#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
//#include <ncurses.h> uncomment for ncurses
#include <unistd.h>
#include <time.h>

// -------------------------------- Aarch64 Functions -------------------------------- //

extern int addNums(int a, int b);
extern int deathCheck(int xpos, int ypos, int width, int height, char snakeChar, char **map);

// -------------------------------- Start Menu -------------------------------- //
#define MAX_NAME_LENGTH 50
#define MAX_PLAYERS 10

typedef struct {
    char name[MAX_NAME_LENGTH];
    int score;
} Player;

int compare(const void *a, const void *b) {
    return ((Player *)b)->score - ((Player *)a)->score;
}

int32_t input ()
{
    int32_t a;
    char b[90];
    printf("Enter Anything to Exit = ");
    scanf(" %s", b);
    printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    return a;
}

// Function to add a new player to the leaderboard
void addLeaderboard(int score) {
   FILE *file = fopen("scores.txt", "r");
    if (!file) {
        // If the file does not exist, initialize it with 5 entries of NULL 0
        file = fopen("scores.txt", "w");
        for (int i = 0; i < 5; i++) {
            fprintf(file, "NULL 0\n");
        }
        fclose(file);
        file = fopen("scores.txt", "r");
        //printf("File initialized with 5 empty entries.\n");
    }

    // Read all existing players into an array
    Player players[MAX_PLAYERS];
    int playerCount = 0;

    // Read existing entries from the file
    while (fscanf(file, "%49s %d", players[playerCount].name, &players[playerCount].score) != EOF && playerCount < MAX_PLAYERS) {
        playerCount++;
    }
    fclose(file);  // Close the file after reading


    Player new_player;
    printf("Enter player's name: ");
    scanf("%s", new_player.name);
    new_player.score = score;

    if (playerCount < MAX_PLAYERS) {
        players[playerCount] = new_player;
        playerCount++;
    }

    // Sort the players by score (descending order)
    qsort(players, playerCount, sizeof(Player), compare);

    // Open the file again to write the sorted scores back
    file = fopen("scores.txt", "w");
    if (!file) {
        perror("Error opening file for writing");
        return;
    }

    // Write the sorted leaderboard back to the file
    for (int i = 0; i < 5; i++) {
        fprintf(file, "%s %d\n", players[i].name, players[i].score);
    }
    fclose(file);
    printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
}

// Function to display the leaderboard with sorted scores
void displayLeaderboard() {
    FILE *file = fopen("scores.txt", "r");
    if (!file) {
        file = fopen("scores.txt", "w");
        for (int i = 0; i < 5; i++) {
            fprintf(file, "NULL 0\n");
        }
        fclose(file);
        file = fopen("scores.txt", "r");
    }

    Player players[MAX_PLAYERS];
    int count = 0;

    // Read players from the file
    while (fscanf(file, "%s %d", players[count].name, &players[count].score) != EOF) {
        count++;
    }
    fclose(file);


    // Display the sorted leaderboard
    printf("------ LEADERBOARD ------\n");
    for (int i = 0; i < 5; i++) {
        printf("%-18s %d\n", players[i].name, players[i].score);
    }
    printf("-------------------------\n");
    //printf("Press any key to exit...\n");

    // Wait for a key input to exit
    int32_t a = input();

    // Clear LeaderBoard
    for (int i = 0; i < 7; i++) {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    }
    return;

}

int32_t getInputSize () 
{
    int32_t result = -1;
    char a[20];
    char one[20] = "1";
    char two[20] = "2";
    char zero[20] = "0";
    printf("-------------------------\n    0: [START]        \n    1: [LEADERBOARD]     \n    2: [EXIT]    \n-------------------------\n");
    printf("Input = [ ]\b\b");
    scanf(" %s", a);
    //printf("%s", a);
    if (strcmp(a, zero) == 0 || strcmp(a, one) == 0 || strcmp(a, two) == 0) 
    {
        result = atoi(a);
    }
    for (int i = 0; i < 6; i++) {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    }
    return result;
}

int64_t setWidth ()
{
    int64_t result;
    char a[20];
    printf("Width = ");
    scanf(" %s", a);
    result = atoi(a);
    if ( result > 100 || result < 1 ) 
    {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
        setWidth ();
    }
    return result;
}

int64_t setHeight ()
{
    int64_t result;
    char a[20];
    printf("Height = ");
    scanf(" %s", a);
    result = atoi(a);
    if ( result > 100 || result < 1 )  
    {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
        //printf("ping");
        return -1;
    }
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
        printf("\033[1A\033[2K");

    return result;
    
}

// ------------------------------------ Game ------------------------------------ //

typedef struct snakeP{ 
    int xpos;
    int ypos;
    struct snakeP *forward;
    struct snakeP *backward;
} snakePart;

// Stay in C
snakePart* createSnakePart(){
    snakePart* newSnakePart = (snakePart*) malloc(sizeof(snakePart));
    newSnakePart->xpos = 0;
    newSnakePart->ypos = 0;
    newSnakePart->forward = NULL;
    newSnakePart->backward = NULL;
    return newSnakePart;
}

// Assembly
/*
char deathCheck(int xpos, int ypos, int width, int height, char snakeChar, char **map){

    if( xpos < 0 || xpos > width-1 || ypos < 0 || ypos > height-1 ){
        return 1;
    } else if( map[ypos][xpos] == snakeChar ){
        return 1;
    } else {
        return 0;
    }
}
*/
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
void printBoard(int boardWidth, int boardHeight, char **map){
    for(int i = 0 ; i < boardWidth ; i++){
        printf(" o");
    }
    printf("\n");
    for(int i = 0 ; i < boardHeight ; i++){
        printf("o");
        for(int j = 0 ; j < boardWidth ; j++){
            printf(" %c", map[i][j]);
        }
        printf("o");
        printf("\n\r");
    }
    for(int i = 0 ; i < boardWidth ; i++){
        printf(" o");
    }
    printf("\n");

}

int getRand(){
    return rand();
}

// Assembly
void placeFood(int boardWidth, int boardHeight, char foodChar, char **graph, int *key, int *hand, int snakeSize){

    // Get a valid position to place our food ( -snakeSize are all the positions of the snake )
    int position = getRand() % ((boardWidth * boardHeight)-snakeSize);

    // Get y and x position from position
    int y = hand[position] / boardWidth;
    int x = hand[position] % boardWidth;

    graph[y][x]=foodChar;
    
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
    snakePart *tempPart = *head;
    snakePart *next = tempPart;
    while (next != NULL) {
        next = next->backward;
        free(tempPart);
        tempPart = next;
    }


    // Delete map
    for(int i = 0 ; i < height ; i++){
        free((*map)[i]);
    }
    free(*map);

    // Delete key and hand
    free(*key);
    free(*hand);

    return;
}

int startGame(int height, int width){

    printf("Loading Game...\n");
    

    //initscr(); // Initialize ncurses // uncomment for ncurses
    //timeout(0); // uncomment for ncurses
    srand(time(NULL));  // Initialize random number generator

    // ------------------ Initialize The Map ------------------- // 
    char **map = NULL;
    initializeMap(&map, height, width);  // initializeMap makes map point to a 2d array allocated with sizes height and width

    // ------------------ Initialize Components for Placeing Food ------------------- // 

    int *key = NULL;
    int *hand = NULL;
    initializeKeyAndHand(&key, &hand, width, height);

    // ---------------------- Initialize Snake ----------------------- //

    // Right now there is a hardcoded snake start size of 3

    int snakeSize=0;
    char snakeChar = '#';
    char foodChar = '@';

    snakePart *tail = createSnakePart();
    snakePart *head = createSnakePart();
    snakePart *body = createSnakePart();

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
        map[tempPart->ypos][tempPart->xpos]=snakeChar;    // Paint the snake character onto the map
        tempPart=tempPart->backward;
    }

    // Place the first food on the map
    placeFood(width, height, foodChar, map, key, hand, snakeSize); 
    
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
        moveHead = createSnakePart();
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
        if(deathCheck(head->xpos, head->ypos, height, width, snakeChar, map)==1){

            // We have died
            running = 0;


        } else if(map[head->ypos][head->xpos]==foodChar){
            
            // Swap new head with length-snakeSize
            int pos1 = (head->ypos*width) + head->xpos;
            int pos2 = hand[(width*height)-snakeSize];
            swapKeyValues(key, hand, pos1, pos2);
            snakeSize++;

            // Dont remove tail
            map[head->ypos][head->xpos] = snakeChar;

            placeFood(width, height, foodChar, map, key, hand, snakeSize);
        } else {

            // Swap old tail and new head in hand (for placing food not on snake)
            int pos1 = (head->ypos*width) + head->xpos;
            int pos2 = (tail->ypos*width) + tail->xpos;
            swapKeyValues(key, hand, pos1, pos2);

            // Remove tail
            map[head->ypos][head->xpos] = snakeChar;
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

    // ---------------------------- Return Score ----------------------------- //

    return snakeSize * 100;

}
