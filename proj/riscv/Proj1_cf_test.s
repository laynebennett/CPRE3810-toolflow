    .text
    .globl main

main:
    addi x2,x0,80
    addi x5,x0,1
    addi x6,x0,2
    addi x7,x0,0
    jal  x1,test1
after_main:
    beq  x0,x0,after_main

test1:
    addi x2,x2,-16
    sw   x1,12(x2)
    blt  x7,x5,test1_taken
test1_not_taken:
    addi x10,x0,1
    beq  x0,x0,test1_after
test1_taken:
    addi x10,x0,2
test1_after:
    jal  x1,test2
    lw   x1,12(x2)
    addi x2,x2,16
    jalr x0,0(x1)

test2:
    addi x2,x2,-16
    sw   x1,12(x2)
    bge  x6,x5,test2_ge
test2_lt:
    addi x11,x0,1
    beq  x0,x0,test2_after
test2_ge:
    addi x11,x0,2
test2_after:
    jal  x1,test3
    lw   x1,12(x2)
    addi x2,x2,16
    jalr x0,0(x1)

test3:
    addi x2,x2,-16
    sw   x1,12(x2)
    bne  x5,x6,test3_ne
test3_eq:
    addi x12,x0,1
    beq  x0,x0,test3_after
test3_ne:
    addi x12,x0,2
test3_after:
    jal  x1,test4
    lw   x1,12(x2)
    addi x2,x2,16
    jalr x0,0(x1)

test4:
    addi x2,x2,-16
    sw   x1,12(x2)
    beq  x5,x5,test4_eq
test4_ne:
    addi x13,x0,1
    beq  x0,x0,test4_after
test4_eq:
    addi x13,x0,2
test4_after:
    jal  x1,test5
    lw   x1,12(x2)
    addi x2,x2,16
    jalr x0,0(x1)

test5:
    addi x2,x2,-16
    sw   x1,12(x2)
    blt  x5,x6,test5_lt
test5_nlt:
    addi x14,x0,1
    beq  x0,x0,test5_after
test5_lt:
    addi x14,x0,2
test5_after:
    lw   x1,12(x2)
    addi x2,x2,16
    jalr x0,0(x1)
