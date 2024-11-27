//
// Assembler program to print "Hello World!"
// to stdout.
//
// X0-X2 - parameters to linux function services
// X8 - linux function number
//

.global main

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
    bl startGame
    mov x0, #90
    bl addLeaderboard
    b next
one:
    //printStr "1: \n"
    bl displayLeaderboard
    b next
two:
    //printStr "2: \n"
    b exit
    

exit:
    //printStr "Exiting..."
// Setup the parameters to exit the program
// and then call Linux to do it.
	mov     X0, #0      // Use 0 return code
        mov     X8, #93      // Service command code 93 terminates this program
        svc     0           // Call linux to terminate the program

.data

state: .fill 1, 1, 0

