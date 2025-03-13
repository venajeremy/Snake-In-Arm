# Snake Game Made in ARM Assembly (Without NCurses - No Live Input)

## About
### For our final project for our ARM assembly course we constructed the classic game of Snake in ARM assembly. We used the NCurses library compiled for aarch64 to get live user input in the terminal and a couple C functions to simplify dynamic memory allocation. This branch contains the final project code for the testing version of our game. Not requiring the NCurses library and without live input, this version requires the player to enter directional input by pressing the key and then enter (See latestWithNCurses branch for live input version).

## Relevant Files:
### build.txt
#### Contains commands to compile project.

### layout.txt
#### Describes how different components of the game are built algorithmically.

### codeModel.c
#### Game was originally created in C and functions were converted into assembly. Algorithm of ARM assembly functions directly follow those written in C.
