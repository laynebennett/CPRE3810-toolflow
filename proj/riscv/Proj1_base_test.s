  .text
    .globl main

main:
    addi x1,x0,10
    addi x2,x0,12
    add  x3,x1,x2
    sub  x4,x3,x1
    and  x5,x1,x2
    or   x6,x1,x2
    xor  x7,x1,x2
    sll  x8,x1,x2
    srl  x9,x8,x2
    sra  x10,x8,x2
    slt  x11,x1,x2
    
    wfi
