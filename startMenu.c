#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
#include <unistd.h>  // For sleep()
#include <termios.h> // For terminal control
#include <fcntl.h>   // For fcntl() and O_NONBLOCK

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
    printf("Enter a Number to Exit = [ ]\b\b");
    scanf(" %d", &a);
    printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    if ( a > 100 ) 
    {
        printf("Invalid input\n");
        input ();
    }
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
    int32_t a = -1;
    printf("-------------------------\n    0: [START]        \n    1: [LEADERBOARD]     \n    2: [EXIT]    \n-------------------------\n");
    printf("Input = [ ]\b\b");
    int result = scanf(" %d", &a);
    if (a > 2 || a < 0 || result != 1) 
    {
        printf("Invalid input\n");
    }
    for (int i = 0; i < 6; i++) {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    }
    return a;
}

int32_t setWidth ()
{
    int32_t a;
    printf("Width = ");
    scanf(" %d", &a);
    
    if ( a > 100 || a < 1 ) 
    {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
        setWidth ();
    }
    return a;
}

int32_t setHeight ()
{
    int32_t a;
    printf("Height = ");
    scanf(" %d", &a);
    
    if ( a > 100 || a < 1 )  
    {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
        setHeight ();
    }
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
        printf("\033[1A\033[2K");

    return a;
    
}



