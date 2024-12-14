.section .data
width:      .word 10      // Example value for width
height:     .word 10      // Example value for height

.section .bss
snakeSize:  .space 4      // Reserve space for an integer
head:       .space 8      // Reserve space for a pointer
body:       .space 8      // Reserve space for a pointer
tail:       .space 8      // Reserve space for a pointer

.section .text
.global _start

_start:
    ldr x0, =snakeSize
    mov w1, #0
    str w1, [x0]

    // Allocate memory for head, body, and tail
    mov x0, #16           // size of snakePart
    bl malloc
    mov x20, x0           // head

    mov x0, #16
    bl malloc
    mov x21, x0           // body

    mov x0, #16
    bl malloc
    mov x22, x0           // tail

    // Initialize head
    ldr w0, =width
    ldr w0, [w0]
    lsr w0, w0, #1        // width / 2
    str w0, [x20]         // head->xpos

    ldr w0, =height
    ldr w0, [w0]
    lsr w0, w0, #1        // height / 2
    str w0, [x20, #4]     // head->ypos

    str x21, [x20, #8]    // head->backward

    // Initialize body
    ldr w0, =width
    ldr w0, [w0]
    lsr w0, w0, #1
    sub w0, w0, #1        // (width / 2) - 1
    str w0, [x21]         // body->xpos

    ldr w0, =height
    ldr w0, [w0]
    lsr w0, w0, #1
    str w0, [x21, #4]     // body->ypos

    str x20, [x21, #8]    // body->forward
    str x22, [x21, #12]   // body->backward

    // Initialize tail
    ldr w0, =width
    ldr w0, [w0]
    lsr w0, w0, #1
    sub w0, w0, #2        // (width / 2) - 2
    str w0, [x22]         // tail->xpos

    ldr w0, =height
    ldr w0, [w0]
    lsr w0, w0, #1
    str w0, [x22, #4]     // tail->ypos

    str x21, [x22, #8]    // tail->forward

    // Paint snake onto map
    mov x23, x20          // tempPart = head

loop:
    cmp x23, #0
    b.eq endloop          // while(tempPart != NULL)

    // Increment snakeSize
    ldr x0, =snakeSize
    ldr w1, [x0]
    add w1, w1, #1
    str w1, [x0]

    // Assuming swapKeyValues and map modification (pseudo code)
    // bl swapKeyValues
    // modify map[tempPart->ypos][tempPart->xpos]

    ldr x23, [x23, #12]   // tempPart = tempPart->backward
    b loop

endloop:
    // Exit program
    mov x0, #0
    mov x8, #93
    svc #0
