.section .bss
inHead:    .space 8    // Reserve space for snakePart* inHead
inTail:    .space 8    // Reserve space for snakePart* inTail
tmp:       .space 8    // Reserve space for snakePart* tmp

.section .data
width:     .word 10    // Example width
height:    .word 10    // Example height

.section .text
.global initializeSnake

initializeSnake:
    // Prologue
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Arguments: 
    // x0 -> inHead
    // x1 -> inTail
    // w2 -> snakeChar
    // w3 -> snakeSize
    // w4 -> width
    // w5 -> height
    // x6 -> key
    // x7 -> hand
    // x8 -> map

    // Call createSnakePart() for head
    bl createSnakePart
    str x0, [x0]             // *inHead = createSnakePart()

    // Set head x and y positions
    ldr w9, =width
    lsr w9, w9, #1           // width / 2
    str w9, [x0]             // (*inHead)->xpos

    ldr w10, =height
    lsr w10, w10, #1         // height / 2
    str w10, [x0, #4]        // (*inHead)->ypos

    // Initialize tmp = *inHead
    str x0, [tmp]

    // Loop to initialize body parts
    mov w11, #1              // i = 1
loop_body:
    cmp w11, w3              // compare i with snakeSize
    b.ge end_body_loop       // if i >= snakeSize, exit loop

    // Create new snakePart for body
    bl createSnakePart

    // Set backward link
    ldr x12, [tmp]
    str x12, [x0, #12]       // tmp->backward = new snakePart

    // Set forward link
    str x0, [x12, #8]        // tmp->backward->forward = tmp

    // Move tmp to the new part
    str x0, [tmp]

    // Set x and y positions for the new part
    ldr w13, =width
    lsr w13, w13, #1
    add w13, w13, w11        // (width/2) + i
    str w13, [x0]

    ldr w14, =height
    lsr w14, w14, #1         // height / 2
    str w14, [x0, #4]

    // Increment i
    add w11, w11, #1
    b loop_body              // repeat loop

end_body_loop:
    // Initialize tail
    bl createSnakePart
    ldr x15, [tmp]
    str x15, [x0, #8]        // (*inTail)->forward = tmp
    str x0, [x15, #12]       // tmp->backward = *inTail

    // Set tail x and y positions
    ldr w16, =width
    lsr w16, w16, #1
    add w16, w16, w3
    sub w16, w16, #1         // (width/2) + snakeSize - 1
    str w16, [x0]            // (*inTail)->xpos

    ldr w17, =height
    lsr w17, w17, #1         // height / 2
    str w17, [x0, #4]        // (*inTail)->ypos

    // Paint snake onto map
    ldr x18, [tmp]
    mov w19, #1              // int32_t i = 1

paint_loop:
    cmp x18, #0
    b.eq end_paint_loop      // while(tmp != NULL)

    // Placeholder for swapKeyValuesA (Not implemented)
    // bl swapKeyValuesA

    // Paint snake character onto the map
    ldr w20, [x18, #4]       // tmp->ypos
    mul w21, w20, w4         // (tmp->ypos * width)
    ldr w22, [x18]           // tmp->xpos
    add w21, w21, w22        // (tmp->ypos * width) + tmp->xpos
    ldr x23, [x8, x21, LSL #3] // map[tmp->ypos]
    strb w2, [x23, w22]      // map[tmp->ypos][tmp->xpos] = snakeChar

    // Move to the next part
    ldr x18, [x18, #12]      // tmp = tmp->backward

    // Increment i
    add w19, w19, #1
    b paint_loop

end_paint_loop:
    // Epilogue
    ldp x29, x30, [sp], #16
    ret

createSnakePart:
    // Placeholder for function
    // Returns pointer to new snakePart
    ret
