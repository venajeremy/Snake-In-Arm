//
// Assembler program to print "Hello World!"
// to stdout.
//
// X0-X2 - parameters to linux function services
// X8 - linux function number
//

.global main

.global addNums

.global deathCheck

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

addNums:
    add x0, x0, x1
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

exit:
    //printStr "Exiting..."
    // Setup the parameters to exit the program
    // and then call Linux to do it.
    mov     X0, #0      // Use 0 return code
    mov     X8, #93     // Service command code 93 terminates this program
    svc     0           // Call linux to terminate the program

.data

state: .fill 1, 1, 0

