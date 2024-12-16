#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
//#include <ncurses.h>
#include <unistd.h>
#include <time.h>


typedef struct snakeP{ 
    int32_t xpos;
    int32_t ypos;
    struct snakeP *forward;
    struct snakeP *backward;
} snakePart;



// -------------------------------- Aarch64 Functions -------------------------------- //

extern int32_t addNums(int32_t a, int32_t b);

extern void cleanUpA(snakePart **head, char ***map, int32_t height, int32_t **hand, int32_t **key);

extern void swapKeyValuesA(int32_t *key, int32_t *hand, int32_t pos1, int32_t pos2);

extern int32_t deathCheckA(int32_t xpos, int32_t ypos, int32_t width, int32_t height, char snakeChar, char **map);

extern int32_t moveHeadAndCheckQuitA(snakePart **head, int32_t *currentDirection);

extern void placeFoodA(int32_t boardWidth, int32_t boardHeight, char foodChar, char **graph, int32_t *key, int32_t *hand, int32_t snakeSize);

extern int32_t startGameA(int32_t height, int32_t width);

// -------------------------------- Start Menu -------------------------------- //
#define MAX_NAME_LENGTH 50
#define MAX_PLAYERS 10

typedef struct {
    char name[MAX_NAME_LENGTH];
    int32_t score;
} Player;

int32_t compare(const void *a, const void *b) {
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
void addLeaderboard(int32_t score) {
   FILE *file = fopen("scores.txt", "r");
    if (!file) {
        // If the file does not exist, initialize it with 5 entries of NULL 0
        file = fopen("scores.txt", "w");
        for (int32_t i = 0; i < 5; i++) {
            fprintf(file, "NULL 0\n");
        }
        fclose(file);
        file = fopen("scores.txt", "r");
        //printf("File initialized with 5 empty entries.\n");
    }

    // Read all existing players int32_to an array
    Player players[MAX_PLAYERS];
    int32_t playerCount = 0;

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
    for (int32_t i = 0; i < 5; i++) {
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
        for (int32_t i = 0; i < 5; i++) {
            fprintf(file, "NULL 0\n");
        }
        fclose(file);
        file = fopen("scores.txt", "r");
    }

    Player players[MAX_PLAYERS];
    int32_t count = 0;

    // Read players from the file
    while (fscanf(file, "%s %d", players[count].name, &players[count].score) != EOF) {
        count++;
    }
    fclose(file);

    // Display the sorted leaderboard
    printf("------ LEADERBOARD ------\n");
    for (int32_t i = 0; i < 5; i++) {
        printf("%-18s %d\n", players[i].name, players[i].score);
    }
    printf("-------------------------\n");
    //printf("Press any key to exit...\n");

    // Wait for a key input to exit
    int32_t a = input();

    // Clear LeaderBoard
    for (int32_t i = 0; i < 7; i++) {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    }
    return;

}

int32_t displayShop()
{
    // Player can buy and equip skin or leave shop
    int32_t result = -1;
    char a[20];
    char zero[20] = "0";
    char one[20] = "1";
    char two[20] = "2";
    char three[20] = "3";
    char four[20] = "4";
    char five[20] = "5";

    printf("Welcome to the Skin Shop! \n -----Skin Shop----- \n");
    printf("Selection:| 1 = # | 2 = $ | 3 = & | 4 = + | 5 = o | 6 = Exit \n");
    printf("Choice = [ ]\b\b");
    scanf(" %s", a);

    for (int32_t i = 0; i < 4; i++) { // Clear Text
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    }
    if (strcmp(a, zero) == 0 || strcmp(a, one) == 0 || strcmp(a, two) == 0 || strcmp(a, three) == 0 || strcmp(a, four) == 0 || strcmp(a, five) == 0) 
    {
        result = atoi(a); // Convert Selection to int
    }
    
    return result;
}

int32_t getInputSize () 
{
    int32_t result = -1;
    char a[20];
    char zero[20] = "0";
    char one[20] = "1";
    char two[20] = "2";
    char three[20] = "3";
    
    

    system("clear");
    printf("-------------------------\n    0: [START]        \n    1: [LEADERBOARD]     \n    2: [SHOP]    \n    3: [EXIT]    \n-------------------------\n");
    printf("Input = [ ]\b\b");
    scanf(" %s", a);
    //printf("%s", a);
    if (strcmp(a, zero) == 0 || strcmp(a, one) == 0 || strcmp(a, two) == 0 || strcmp(a, three) == 0) 
    {
        result = atoi(a);
    }
    for (int32_t i = 0; i < 6; i++) {
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
    printf("xpos: %d, ypos: %d, width: %d, height: %d, snakeChar %d, map: \"%c\"\n", xpos, ypos, width, height, snakeChar, map[2][2]);
    if( xpos < 0 || xpos > width-1 || ypos < 0 || ypos > height-1 ){
        return 1;
    } else if( map[ypos][xpos] == snakeChar ){
        return 1;
    } else {
        return 0;
    }

}
*/
/*  uncomment for ncurses
void wipe(){
    clear();
    refresh();
}
*/

// Stay in C
int32_t getInput(){
    
    int32_t input;
    input = getchar();
    while(getchar() != '\n');
    return input;
    
    /*
    int32_t input = getch();
    while(getch()!=ERR){
    }
    */

    return input;
}

// Stay in C
void printBoard(int32_t boardWidth, int32_t boardHeight, char **map){
    for(int32_t i = 0 ; i < boardWidth ; i++){
        printf(" o");
    }
    printf("\n\r");
    for(int32_t i = 0 ; i < boardHeight ; i++){
        printf("o");
        for(int32_t j = 0 ; j < boardWidth ; j++){
            printf(" %c", map[i][j]);
        }
        printf("o");
        printf("\n\r");
    }
    for(int32_t i = 0 ; i < boardWidth ; i++){
        printf(" o");
    }
    printf("\n\r");

}

int32_t getRand(){
    int32_t x = rand();
    //printf("%d",x );
    return x;
}


// Assembly
/*
void placeFood(int32_t boardWidth, int32_t boardHeight, char foodChar, char **graph, int32_t *key, int32_t *hand, int32_t snakeSize){

    // Get a valid position to place our food ( -snakeSize are all the positions of the snake )
    int32_t position = getRand() % ((boardWidth * boardHeight)-snakeSize-1);

    // Get y and x position from position
    int32_t y = hand[position] / boardWidth;
    int32_t x = hand[position] % boardWidth;

    graph[y][x]=foodChar;
    
    return;
}
*/


// Assembly
/*
void swapKeyValues(int32_t *key, int32_t *hand, int32_t pos1, int32_t pos2){
    printf("key: %d, hand: %d, pos1: %d, pos2: %d\n", key[3], hand[3], pos1, pos2);
   int32_t location1 = key[pos1];
   int32_t location2 = key[pos2];
   hand[location1] = pos2;
   hand[location2] = pos1;
   key[pos1] = location2;
   key[pos2] = location1;
   return;
}
*/



// Stay in C
void initializeMap(char ***map, int32_t height, int32_t width){

    *map = (char**) malloc(sizeof(char*) * height);   // Allocate rows of 2d Array

    for(int32_t i = 0 ; i < height ;  i++){
        (*map)[i] = (char*) malloc(sizeof(char) * width);      // Allocate all columns of 2d Array
        for(int32_t j = 0 ; j < width ;  j++){
            (*map)[i][j] = ' ';                                // Initialize values of 2d Array
        }   
    }

}

// Stay in C
void initializeKeyAndHand(int32_t **key, int32_t **hand, int32_t width, int32_t height){
    // Initialize arrays for placing food
    (*key) = (int32_t*) malloc(sizeof(int32_t) * width * height);     // Used to hold the location of a food position in the hand

    (*hand) = (int32_t*) malloc(sizeof(int32_t) * width * height);    // Used to hold food positions avaiable to pick randomly
    
    // Initialize every food position at its index
    for(int32_t i = 0 ; i < width*height ; i++){
        (*key)[i] = i;
        (*hand)[i] = i;
    }
}

// Went to Assembly
/*
void cleanUp(snakePart **head, char ***map, int32_t height, int32_t **hand, int32_t **key){ 

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
    for(int32_t i = 0 ; i < height ; i++){
        free((*map)[i]);
    }
    free(*map);

    // Delete key and hand
    free(*key);
    free(*hand);

    return;
}
*/


// Assembly
void initializeSnake(snakePart **inHead, snakePart **inTail, char snakeChar, int32_t snakeSize, int32_t width, int32_t height, int *key, int *hand, char **map){

    *inHead = createSnakePart();

    (*inHead)->xpos = width/2;
    (*inHead)->ypos = height/2;

    snakePart *tmp = *inHead;
    for(int32_t i = 1 ; i < snakeSize-1 ; i++){
        tmp->backward = createSnakePart();
        tmp->backward->forward = tmp;
        tmp = tmp->backward;
        tmp->xpos = (width/2)+i;
        tmp->ypos = (height/2);
    }
    *inTail = createSnakePart();
    (*inTail)->forward = tmp;
    tmp->backward = *inTail;

    (*inTail)->xpos = (width/2)+snakeSize-1;
    (*inTail)->ypos = (height/2);

     // Paint snake onto map
    tmp = *inHead;
    int32_t i=1;
    while(tmp!=NULL){
        swapKeyValuesA(key, hand, (tmp->ypos*width)+tmp->xpos, width*height-i);  // Add new part to correct postion of key and hand
        map[tmp->ypos][tmp->xpos]=snakeChar;    // Paint32_t the snake character onto the map
        tmp=tmp->backward;
        i++;
    }


    return;
}


/*
// Went to Assembly    I also had to change currentDirection to take a pointer
int32_t moveHeadAndCheckQuit(snakePart **head, int32_t currentDirection){
    int32_t running=1;

    // Create new Head
    snakePart *moveHead = createSnakePart();
    (*head)->forward=moveHead;
    moveHead->backward=(*head);
    moveHead->xpos=(*head)->xpos;
    moveHead->ypos=(*head)->ypos;
    
    // Get input
    int32_t ch = getInput();

    // Clear previous board
    // uncomment for ncurses (delete above clear method)
    //clear(); 
    //refresh();
     

    system("clear");    // delete if using ncurses

    // No input entered check
    if(ch=='a'||ch=='d'||ch=='w'||ch=='s'||ch=='q'){
        currentDirection = ch;
    }
    // uncomment for ncurses and delete above (maybe we should keep above for ease in assembly)
    //if(ch!=ERR){
    //currentDirection = ch;
    //}
    

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
    *head=moveHead;

    return running;
}
*/

void printReg(unsigned long long reg) {
    printf("Register value: 0x%llx\n", reg);
    //return;
}

int32_t startGame(int32_t height, int32_t width){

    //                V   V   V  R,G,B Color values for text
    printf("\033[38;2;255;0;0mTesting version without live input (ncurses)! Enter an input and press enter to start.\033[0m\n");

    return startGameA(height, width);

    /*
    //initscr(); // Initialize ncurses // uncomment for ncurses
    //timeout(0); // uncomment for ncurses
    srand(time(NULL));  // Initialize random number generator

    // ------------------ Initialize The Map ------------------- // 
    char **map = NULL;
    initializeMap(&map, height, width);  // initializeMap makes map point32_t to a 2d array allocated with sizes height and width

    // ------------------ Initialize Components for Placeing Food ------------------- // 

    int32_t *key = NULL;
    int32_t *hand = NULL;
    initializeKeyAndHand(&key, &hand, width, height);

    // ---------------------- Initialize Snake ----------------------- //

    // Right now there is a hardcoded snake start size of 3

    int32_t snakeSize=3;
    char snakeChar = '#';
    
    snakePart *head = createSnakePart();
    snakePart *tail = createSnakePart();
   
    initializeSnake(&head, &tail, snakeChar, snakeSize, width, height, key, hand, map);

    // ---------------------- Place First Food ----------------------- //

    char foodChar = '@';
    //printf("ping");
    // Place the first food on the map
    placeFoodA(width, height, foodChar, map, key, hand, snakeSize);
    //printf("ping2");

    // ---------------------- Initialize Variables ----------------------- //
    
    // Create variables for game loop
    int32_t currentDirection='a';   // Store current input

    // Game loop
    char running=1;

    // Start Game Loop
    while(running==1){

        // Clear previous board
        // uncomment for ncurses (delete above clear method)
        //clear(); 
        //refresh();
        // 

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
        // uncomment for ncurses and delete above
        //if(ch!=ERR){
        //currentDirection = ch;
        //}
        

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
        if(deathCheckA(head->xpos, head->ypos, height, width, snakeChar, map)==1){
            // We have died
            running = 0;


        } else if(map[head->ypos][head->xpos]==foodChar){
            
            // Swap new head with length-snakeSize
            int32_t pos1 = (head->ypos*width) + head->xpos;
            int32_t pos2 = hand[(width*height)-snakeSize-1];
            swapKeyValuesA(key, hand, pos1, pos2);
            snakeSize++;

            // Dont remove tail
            map[head->ypos][head->xpos] = snakeChar;

            placeFoodA(width, height, foodChar, map, key, hand, snakeSize);
        } else {

            // Swap old tail and new head in hand (for placing food not on snake)
            int32_t pos1 = (head->ypos*width) + head->xpos;
            int32_t pos2 = (tail->ypos*width) + tail->xpos;
            
            swapKeyValuesA(key, hand, pos1, pos2);

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
    
    cleanUpA(&head, &map, height, &hand, &key);

    // ---------------------------- Return Score ----------------------------- //

    return snakeSize * 100;

    */
