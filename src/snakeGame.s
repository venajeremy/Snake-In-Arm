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

exit:
    //printStr "Exiting..."
// Setup the parameters to exit the program
// and then call Linux to do it.
	mov     X0, #0      // Use 0 return code
    mov     X8, #93      // Service command code 93 terminates this program
    svc     0           // Call linux to terminate the program

.data

state: .fill 1, 1, 0

