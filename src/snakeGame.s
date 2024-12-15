//
// Assembler program to print "Hello World!"
// to stdout.
//
// X0-X2 - parameters to linux function services
// X8 - linux function number
//

.global main

.global addNums

.global cleanUpA

.global swapKeyValuesA

.global deathCheck

.global moveHeadAndCheckQuitA

.global startGameA

.text

main:   
    
next:
    //printReg 20
    mov x0, #-1
    bl getInputSize
    cbz x0, zero
    cmp x0, #1
    b.eq one
    cmp x0, #2
    b.eq two
    //printReg 0
    b next
zero:
    //printStr "0: \n"
    bl setWidth
    mov x20, x0
back:
    bl setHeight
    //printReg 0
    cmp x0, #-1
    b.eq back
    mov x21, x0
    mov x0, x20
    mov x1, x21
    bl startGame
    bl addLeaderboard
    b next
one:
    //printStr "1: \n"
    bl displayLeaderboard
    b next
two:
    //printStr "2: \n"
    b exit

cleanUpA:
    // x1: char ***map
    // x2: int height
    // x3: int **hand
    // x4: int **key
    // x5: snakePart **head
    // x6: snakePart *tempPart
    // x7: snakePart *next
   
    mov x5, x0

    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    //bl endwin uncomment for ncurses
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    // Delete snake

    
    //snakePart *tempPart = *head
    ldr x6, [x5]
    //snakePart *next = tempPart
    mov x7, x6
    
    stp x30, x0, [sp, #-16]!
    bl cleanUpA_deleteSnakeLoop
    ldp x30, x0, [sp], #16

    mov x8, 0
    stp x30, x0, [sp, #-16]!
    bl cleanUpA_deleteMapLoop
    ldp x30, x0, [sp], #16

    ret


cleanUpA_deleteSnakeLoop:
    // next == NULL?
    cmp x7, #0
    b.eq return

    // next = next->backward
    // next  next  4+4+8  (int32 + int32 + pointer)
    //  V     V     V
    ldr x7, [x7, #16]

    // free(tempPart);
    mov x0, x6

    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x30, [sp, #-16]!
    stp x7, x8, [sp, #-16]!
    bl free
    ldp x7, x8, [sp], #16
    ldp x6, x30, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    // tempPart = next;
    mov x6, x7

    b cleanUpA_deleteSnakeLoop

cleanUpA_deleteMapLoop:
    // x8: i =0
    cmp x8, x2
    b.ge return

    // calculate shift for freeing rows lsl 3 for x 8 for byte size of memory address 
    lsl x9, x8, #3 

    // x10: *map
    ldr x10, [x1]

    // x11: *map[i]
    ldr x0, [x10,x9]

    // free((*map)[i])
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x30, [sp, #-16]!
    bl free
    ldp x6, x30, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    // i++
    add x8, x8, 1
 
    b cleanUpA_deleteMapLoop


swapKeyValuesA:
    // x0: int32_t *key
    // x1: int32_t *hand
    // x2: int32_t pos1
    // x3: int32_t pos2

    // x4: int32_t location1
    // x5: int32_t location2

    // location1 = key[pos1]
    ldr w4, [x0, x2, lsl #2]
    // location2 = key[pos2]
    ldr w5, [x0, x3, lsl #2]

    // hand[location1] = pos2
    str w3, [x1, x4, lsl #2]
    // hand[location2] = pos1
    str w2, [x1, x5, lsl #2]

    // key[pos1] = location2
    str w5, [x0, x2, lsl #2]
    // key[pos2] = location1
    str w4, [x0, x3, lsl #2]

    ret


addNums:
    add x0, x0, x1
    ret


return:
    ret

deathCheck:
    cmp x0, 0                   // xpos < 0
    blt return1
    
    add x2, x2, -1              // width - 1
    cmp x0, x2                  // xpos > width - 1
    bgt return1

    cmp x1, 0                   // ypos < 0
    blt return1

    add x3, x3, -1              // height - 1
    cmp x1, x3                  // ypos > height - 1
    bgt return1

    ldr x6, [x5, x1, lsl 3]     // value of map[xpos][ypos]
    add x6, x6, x0
    ldrb w7, [x6]

    cmp w7, w4                  // map[xpos][ypos] == snakeChar
    beq return1

    mov x0, 0
    ret

return1:
    mov x0, 1  
    ret

moveHeadAndCheckQuitA:
    //Inputs:
    //x0: snakePart **head
    //x1: int32_t *currentDirection

    //Variables:
    //x2: int32_t running
    //x3: snakePart *moveHead
    //x4: int32_t ch
    //x12: int32_t currentDirection

    // running = 1
    mov x2, #1

    // snakePart *moveHead = createSnakePart
    stp x0, x1, [sp, #-16]!
    stp x2, x4, [sp, #-16]!
    stp x5, x30, [sp, #-16]!
    // x0 now has the pointer to the newly allocated snake part
    bl createSnakePart
    // save that to x3
    mov x3, x0
    // we only save and load the other registers
    ldp x5, x30, [sp], #16
    ldp x2, x4, [sp], #16
    ldp x0, x1, [sp], #16

    // (*head)->forward=moveHead
    // Step 1: dereference **head and get memory address of actual head
    ldr x5, [x0]
    // Step 2: update the forward at the address with our newHead we just created
    //            V = (int32_t(4) + int32_t(4)) = starting address of forward  
    str x3, [x5, #8]

    // moveHead->backward=(*head)
    //            V = (int32_t(4) + int32_t(4) + memoryAdd(8)) = starting address of backward 
    str x5, [x3, #16]

    //moveHead->xpos = (*head)->xpos
    //moveHead->ypos = (*head)->ypos

    // Step 1: get (*head)->xpos and (*head)->xpos
    // x6: (*head)->xpos ( no shift )
    ldr w6, [x5]
    // x7: (*head)->ypos ( shift 4 for int32_t )
    ldr w7, [x5, #4]

    // Step 2: load these values into movehead
    str w6, [x3]
    str w7, [x3, #4]

    // Get input
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x30, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    // x0 now has user's input
    bl getInput;
    // save that to x4
    mov x4, x0
    // we only save and load the other registers
    ldp x6, x7, [sp], #16
    ldp x30, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16


    /* uncomment for ncurses
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x30, [sp, #-16]!
    bl clear
    bl refresh
    ldp x8, x30, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16
    */
    // Start comment for ncurses
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x30, [sp, #-16]!
    ldr x0, =clear
    // clear terminal
    bl system;
    // we only save and load the other registers
    ldp x8, x30, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16
    // End comment for ncurses


    // Movement checks

    // Last direction
    ldr w12, [x1]

    // x4: ch   ( new user direction )
    // x12: currentDireciton ( previous direction )

    /* ascii direciton key:
        'w' = 119
        'a' = 97
        's' = 115
        'd' = 100

        'q' = 113   
    */
    // No input entered check
    
    cmp x4, #119
    b.eq updateCurrentDirection
    cmp x4, #97
    b.eq updateCurrentDirection
    cmp x4, #115
    b.eq updateCurrentDirection
    cmp x4, #100
    b.eq updateCurrentDirection
    cmp x4, #113
    b.eq updateCurrentDirection

    b handleMovement


updateCurrentDirection:
    // If we entered a valid input updatea the current direction (x1) to be the entered input(x4)
    mov x12, x4

    b handleMovement

handleMovement:

    // move in the direction of currentDirection (x12) ( we already updated it if a valid input was entered )
    

    /* ascii direciton key:
        'w' = 119
        'a' = 97
        's' = 115
        'd' = 100

        'q' = 113   
    */

    // if(currentDirection=='a'):
    cmp x12, #97
    b.eq moveLeft

    // if(currentDirection=='d'):
    cmp x12, #100
    b.eq moveRight

    // if(currentDirection=='w'):
    cmp x12, #119
    b.eq moveUp

    // if(currentDirection=='s'): 
    cmp x12, #115
    b.eq moveDown

    // if(currentDirection=='q'):
    cmp x12, #113
    b.eq moveQuit


// x6: old xpos
// x7: old ypos

moveLeft:
    // moveHead->xpos--;
    sub x6, x6, #1
    b movementFinish

moveRight:
    // moveHead->xpos++;
    add x6, x6, #1
    b movementFinish

moveUp:
    // moveHead->ypos--;
    sub x7, x7, #1
    b movementFinish

moveDown:
    // moveHead->ypos++;
    add x7, x7, #1
    b movementFinish

moveQuit:
    // running = 0;
    mov x2, #0
    b movementFinish

movementFinish:

    // update the positions of the new head
    // moveHead->xpos = new xpos (x6)
    str w6, [x3]
    // moveHead->ypos = new ypos (x7)
    //            V = (int32_t(4) memory address of forward)
    str w7, [x3, #4]

    // *head=moveHead
    // Make head point to newhead
    str x3, [x0]

    // update current direction
    str w12, [x1]

    // return running
    mov x0, x2
    ret

startGameA:
    // Inputs:
    // x0: int32_t height
    // x1: int32_t width

    // srand(time(NULL))
    stp x0, x1, [sp, #-16]!
    stp x2, x30, [sp, #-16]!
    mov x0, #0 // NULL
    bl time
    // x0 has return
    bl srand
    ldp x2, x30, [sp], #16
    ldp x0, x1, [sp], #16

    // Variables:
    // x0: int32_t height
    // x1: int32_t width
    // x2: char **map
    // x3: int32_t *key
    // x4: int32_t *hand
    // x5: int32_t snakeSize
    // x6: char snakeChar
    // x7: char foodChar
    // x8: int32_t currentDirection
    // x9: char running

    

    // -------------------------- Game Customizable Variables -------------------------- //

     // snakesize: SET HERE CAN CHANGE:
    //       V
    mov x5, #3

    // snakechar: SET HERE CAN CHANGE:
    //       V = '#'
    mov x6, #35

    // foodchar: SET HERE CAN CHANGE:
    //       V = '@'
    mov x7, #64

    // currentdirection: SET HERE CAN CHANGE:
    //       V = 'a' = to left
    mov x8, #97

    // -------------------------- Cont. -------------------------- //

    // running: (cant really change this one)
    mov x9, #1

    // InitializeMap(&map, height, width);
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!
    
    // initializeMap(&map, height, width)
    mov x2, x1
    mov x1, x0
    ldr x0, =map
    

    bl initializeMap

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    

    // Initialize Components for Placing Food
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!
    
    // initializeKeyAndHand(&key, &hand, width, height)
    mov x2, x1
    mov x3, x0
    ldr x0, =key
    ldr x1, =hand

    bl initializeKeyAndHand

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16


    // initializeSnake(snakePart **inHead, snakePart **inTail, char snakeChar, int32_t snakeSize, int32_t width, int32_t height, int *key, int *hand, char **map)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!
    
    mov x2, x6  // snakeChar
    mov x3, x5  // snakeSize
    mov x4, x1  // width
    mov x5, x0  // height
    
    

    ldr x0, =head   //head
    ldr x1, =tail   //tail
    
    ldr x6, =key
    ldr x6, [x6]

    ldr x7, =hand
    ldr x7, [x7]

    ldr x8, =map
    ldr x8, [x8]
    
    sub sp, sp, #8    // Reserve space on the stack for 9th argument an int32
    str x8, [sp, #0]   // Store 9th argument at [sp]

    bl initializeSnake
    


    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

/*

    // placeFood(width, height, foodChar, map, key, hand, snakeSize);
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!
    
    mov x15, x0

    mov x0, x1  // width
    mov x1, x15 // height
    mov x2, x7    // foodchar
    ldr x3, =map
    ldr x3, [x3]    // map
    ldr x4, =key
    ldr x4, [x4]    // key
    mov x6, x5      // snakeSize
    ldr x5, =hand
    ldr x5, [x5]    // hand

    bl placeFood

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

*/
    
    b gameLoop

gameLoop:
    // Variables reminder:
    // x0: int32_t height
    // x1: int32_t width
    // x2: char **map
    // x3: int32_t *key
    // x4: int32_t *hand
    // x5: int32_t snakeSize
    // x6: char snakeChar
    // x7: char foodChar
    // x8: int32_t currentDirection
    // x9: char running


    b cleanUpThenExit
    


cleanUpThenExit:
    


    b exit



exit:
    //printStr "Exiting..."
    // Setup the parameters to exit the program
    // and then call Linux to do it.
    mov     X0, #0      // Use 0 return code
    mov     X8, #93     // Service command code 93 terminates this program
    svc     0           // Call linux to terminate the program

.data

state: .fill 1, 1, 0
clear: .asciz "clear"

// Memory for Main Game Function
map: .quad 0
key: .quad 0
hand: .quad 0
head: .quad 0
tail: .quad 0
currentDirection: .word 0

    



