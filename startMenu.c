#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>

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



