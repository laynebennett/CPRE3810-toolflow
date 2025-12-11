    .text
    .globl main

main:
    lui   sp, 0x10010
    addi  sp, sp, 0

    addi  t0, x0, 1
    addi  t1, x0, 2

    jal   ra, test1

main_done:
    addi  a7, x0, 10
    ecall
    wfi
    addi x0, x0, 0


test1:
    addi  sp, sp, -4
    sw    ra, 0(sp)        # save RA from main (points to main_done)

    jal   ra, test2        # call test2


test2:
    addi  sp, sp, -4
    sw    ra, 0(sp)

    jal   ra, test3


test3:
    addi  sp, sp, -4
    sw    ra, 0(sp)

    jal   ra, test4


test4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    beq   t0, t0, L_beq
    
L_beq:
    bne   t0, t1, L_bne
L_bne:
    blt   t0, t1, L_blt
L_blt:
    bge   t1, t0, L_bge
L_bge:
    lw    t3, 12(sp)       # RA from main
    jalr  x0, 0(t3)        # single, non-nested jalr to main_done
