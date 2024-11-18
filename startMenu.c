#include <stdio.h>
#include <stdint.h>


int32_t getInput () 
{
    int32_t a;
    printf("-------------------------\n    0: [START]        \n    1: [LEADERBOARD]     \n    2: [EXIT]    \n-------------------------\n");
    printf("Input = [ ]\b\b");
    scanf(" %d", &a);
    for (int i = 0; i < 6; i++) {
        printf("\033[1A\033[2K"); // Move cursor up one line, then clear the line
    }
    if (a > 2 || a < 0) 
    {
        printf("Invalid input\n");
        //getInput();
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



