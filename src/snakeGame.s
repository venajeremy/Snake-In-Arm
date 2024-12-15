//
// Snake Game Built with Assembly
//
// Some Functions Still Included in SnakeGame.c
//

.global main

.global addNums

.global cleanUpA

.global swapKeyValuesA

.global deathCheckA

.global moveHeadAndCheckQuitA

.global placeFoodA

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
   
    //mov x5, x0

    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    bl endwin

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    // Delete snake


    //snakePart *tempPart = *head
    ldr x6, =head
    ldr x6, [x6]
    //snakePart *next = tempPart
    mov x7, x6

    stp x30, x0, [sp, #-16]!
    bl cleanUpA_deleteSnakeLoop
    ldp x30, x0, [sp], #16

    mov x8, #0
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
    add x8, x8, #1

    b cleanUpA_deleteMapLoop

placeFoodA:
    //x0 = int32_t boardWidth
    //x1 = int32_t boardHeight
    //x2 = char foodChar
    //x3 = char **graph
    //x4 = int32_t *key
    //x5 = int32_t *hand
    //x6 = int32_t snakeSize

    stp x30, x0, [sp, #-16]!
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    stp x5, x6, [sp, #-16]!

    bl getRand
    mov w7, w0 //x7 = randNum

    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ldp x30, x0, [sp], #16

    //x9 = position
    mul w8, w0, w1    // w*h
    sub x8, x8, x6    // (w*h) - s
    sub x8, x8, #1    // (w*h) - s -1
    udiv x9, x7, x8   // r/((w*h) - s -1)
    mul x13, x9, x8    // x9 = r - ( ((r / (w*h - s)))  *  ((w*h) - s) )
    sub x9, x7, x13

    //x10 = hand[position]
    //mov x0, x9
    //bl printReg

    ldrsw x10, [x5, x9, lsl #2]

    //mov x0, x10
    //bl printReg

    //x11 = y
    udiv x11, x10, x0

    //mov x0, x11
    //bl printReg

    //x12 = x
    udiv x12, x10, x0
    mul x13, x12, x0    
    sub x12, x10, x13

    //mov x0, x12
    //bl printReg

    //graph[y][x]
    ldr x15, [x3, x11, lsl #3]

    //ldr x16, [x15, x12, lsl #3]

    strb w2, [x15, x12]

    ret

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


deathCheckA:
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


    /*
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
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    ldr x0, =clear
    // clear terminal
    bl system;
    // we only save and load the other registers
    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
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

    bl initscr
    mov x0, #0
    bl timeout

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

    sub sp, sp, #8  // Reserve space on the stack for 9th argument an int32
    str x8, [sp, #0]    // Store 9th argument at [sp]

    bl initializeSnake

    add sp, sp, #8  // Retrieve space   

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16



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

    bl placeFoodA

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

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


    cmp x9, #1
    b.ne cleanUpThenExit

    // running = moveHeadAndCheckQuit

    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x11, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    ldr x0, =head

    ldr x1, =currentDirection

    bl moveHeadAndCheckQuitA

    mov x9, x0

    ldp x10, x30, [sp], #16
    ldp x11, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    // deathCheck(head->xpos, head->ypos, height, width, snakeChar, map)==1

    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    mov x2, x0
    mov x3, x1
    mov x4, x6
    ldr x5, =map
    ldr x5, [x5]

    ldr x0, =head
    ldr x0, [x0]
    mov x1, #0
    ldrsw x1, [x0, #4]
    mov x6, #0
    ldrsw x6, [x0]
    mov x0, x6

    bl deathCheckA

    cmp x0, #1

    b.eq died

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    // map[head=>ypos][head->xpos]==foodChar
    ldr x11, =head
    ldr x11, [x11]
    mov x12, #0
    ldrsw x12, [x11, #4]    // head->y
    mov x13, #0
    ldrsw x13, [x11]        
    mov x11, x13            // head->x


    ldr x13, =map
    ldr x13, [x13]
    ldr x13, [x13, x12, lsl #3] // get map[y]

    ldrb w13, [x13, x11]        // get map[y][x]




    cmp x13, x7
    b.eq ateFood

    // normal move



    mul x14, x12, x1
    add x14, x14, x11   // pos1

    ldr x17, =tail
    ldr x17, [x17]
    mov x18, #0
    ldrsw x18, [x17, #4]    // tail->y
    mov x19, #0
    ldrsw x19, [x17]
    mov x17, x19    // tail->x

    mul x15, x18, x1
    add x15, x15, x17   // pos2

    // swapKeyValuesA(key, hand, pos1, pos2)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!
    stp x12, x11, [sp, #-16]!
    stp x18, x17, [sp, #-16]!

    ldr x0, =key
    ldr x0, [x0]

    ldr x1, =hand
    ldr x1, [x1]

    mov x2, x14
    mov x3, x15

    bl swapKeyValuesA

    ldp x18, x17, [sp], #16
    ldp x12, x11, [sp], #16
    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16



    // Remove tail

    ldr x11, =head
    ldr x11, [x11]
    mov x12, #0
    ldrsw x12, [x11, #4]    // head->y
    mov x13, #0
    ldrsw x13, [x11]        
    mov x11, x13            // head->x

    ldr x20, =map
    ldr x20, [x20]

    ldr x21, [x20, x12, lsl #3]     //map[head->ypos]
    strb w6, [x21, x11]        //map[head->ypos][head->xpos] = snakeChar



    ldr x17, =tail
    ldr x17, [x17]
    mov x18, #0
    ldrsw x18, [x17, #4]    // tail->y
    mov x19, #0
    ldrsw x19, [x17]
    mov x17, x19    // tail->x

    ldr x20, =map
    ldr x20, [x20]

    ldr x22, [x20, x18, lsl #3]      //map[tail->ypos]
    mov x29, #32    // ' '
    strb w29, [x22, x17]         //map[tail->ypos][tail->xpos] = ' '

    // tail = tail->forward
    ldr x20, =tail
    ldr x20, [x20]

    ldr x21, [x20, #8]  // 21: tail->forward

    ldr x22, =tail
    str x21, [x22]  // tail = tail->forward




    // free(tail->backward)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    ldr x0, =tail
    ldr x0, [x0, #16]   // x0: free

    bl free

    ldr x0, =tail

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16


    //tail->backward = null
    ldr x20, =tail
    mov x21, #0         // x21: NULL
    str x21, [x20, #16]

    b gameLoopCont


ateFood:

    // pos1 = (head->ypos*width) + head->xpos
    ldr x20, =head
    ldr x20, [x20]
    mov x21, #0
    ldrsw x21, [x20]    //head->xpos
    mov x22, #0
    ldrsw x22, [x20, #4]
    mov x20, #0
    mov x20, x22            //head->ypos

    mov x22, #0
    mul x22, x20, x1
    add x22, x22, x21   //pos1

    // pos2 = hand[(width*height)-snakeSize-1];
    mul x23, x0, x1    // with*height
    sub x23, x23, x5    // with*height -snakesize
    sub x23, x23, #1    // with*height -snakesize-1

    ldr x24, =hand
    ldr x24, [x24]

    ldrsw x24, [x24, x23, lsl #2]   // pos 2

    // swapKeyValuesA(key, hand, pos1, pos2)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    ldr x0, =key
    ldr x0, [x0]

    ldr x1, =hand
    ldr x1, [x1]

    mov x2, x22 //pos 1
    mov x3, x24 //pos 2

    bl swapKeyValuesA

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    //snakeSize++
    add x5, x5, #1


    // map[head->ypos][head->xpos] = snakeChar;
    ldr x11, =head
    ldr x11, [x11]

    mov x12, #0
    ldrsw x12, [x11] // head->xpos
    mov x13, #0
    ldrsw x13, [x11, #4] //head->ypos

    ldr x11, =map
    ldr x11, [x11]
    ldr x11, [x11, x13, lsl #3] // map[head->ypos]
    strb w6, [x11, x12]  // map[head->ypos][head->xpos] = snakechar

    // placeFood(width, height, foodChar, map, key, hand, snakeSize)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    mov x15, x0
    mov x0, x1
    mov x1, x15

    mov x2, x7

    ldr x3, =map
    ldr x3, [x3]

    ldr x4, =key
    ldr x4, [x4]

    mov x6, x5

    ldr x5, =hand
    ldr x5, [x5] 

    bl placeFoodA

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16


    b gameLoopCont

died:

    mov x9, #0

    ldp x10, x30, [sp], #16
    ldp x8, x11, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    b gameLoopCont

gameLoopCont:

    // printBoard(width, height, map)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    mov x15, x0
    mov x0, x1
    mov x1, x15
    ldr x2, =map
    ldr x2, [x2]

    bl printBoard



    // usleep(250000)
    mov x0, 0x3d0
    lsl x0, x0, #8
    movk x0, 0x90   // 250000

    bl usleep

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    b gameLoop

cleanUpThenExit:

    // printBoard(width, height, map)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x30, [sp, #-16]!

    mov x2, x0

    ldr x0, =head

    ldr x1, =map

    ldr x3, =hand

    ldr x4, =key

    bl cleanUpA

    ldp x10, x30, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16

    mov x1, #100
    mul x0, x5, x1   // return snakeSize * 100


    ret

exit:
    //printStr "Exiting..."
// Setup the parameters to exit the program
// and then call Linux to do it.
	mov     X0, #0      // Use 0 return code
    mov     X8, #93      // Service command code 93 terminates this program
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

    



