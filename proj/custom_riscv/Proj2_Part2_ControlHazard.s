.data

.text
.globl main

main:
        addi x1,  x0, 5
        addi x2,  x0, 5
        addi x3,  x0, 10
        addi x4,  x0, -5
        addi x5,  x0, 0

# BEQ taken
beq_test:
        addi x10, x0, 0
        beq  x1, x2, beq_taken
        addi x10, x0, 999
beq_taken:
        addi x10, x0, 1

# BEQ not taken
beq_not_taken_test:
        addi x11, x0, 0
        beq  x1, x3, beq_skip
        addi x11, x0, 2
beq_skip:

# BNE taken
bne_test:
        addi x12, x0, 0
        bne  x1, x3, bne_taken
        addi x12, x0, 999
bne_taken:
        addi x12, x0, 3

# BNE not taken
bne_not_taken_test:
        addi x13, x0, 0
        bne  x1, x2, bne_skip
        addi x13, x0, 4
bne_skip:

# BLT taken
blt_test:
        addi x14, x0, 0
        blt  x1, x3, blt_taken
        addi x14, x0, 999
blt_taken:
        addi x14, x0, 5

# BLT not taken
blt_not_taken_test:
        addi x15, x0, 0
        blt  x3, x1, blt_skip
        addi x15, x0, 6
blt_skip:

# BGE taken
bge_test:
        addi x16, x0, 0
        bge  x3, x1, bge_taken
        addi x16, x0, 999
bge_taken:
        addi x16, x0, 7

# BGE equal
bge_equal_test:
        addi x17, x0, 0
        bge  x1, x2, bge_eq_taken
        addi x17, x0, 999
bge_eq_taken:
        addi x17, x0, 8

# BLTU taken
bltu_test:
        addi x18, x0, 0
        bltu x1, x4, bltu_taken
        addi x18, x0, 999
bltu_taken:
        addi x18, x0, 9

# BGEU taken
bgeu_test:
        addi x19, x0, 0
        bgeu x4, x1, bgeu_taken
        addi x19, x0, 999
bgeu_taken:
        addi x19, x0, 10

# JAL
jal_test:
        addi x21, x0, 0
        jal  x20, jal_target
        addi x21, x0, 999
jal_target:
        addi x21, x0, 11

# JALR
jalr_test:
        addi x22, x0, 0
        la   x23, jalr_target
        jalr x24, 0(x23)
        addi x22, x0, 999
jalr_target:
        addi x22, x0, 12

# Backward branch loop
loop_test:
        addi x25, x0, 0
        addi x26, x0, 3
loop:
        addi x25, x25, 1
        blt  x25, x26, loop

# Branch with forwarding
branch_forward_test:
        addi x27, x0, 0
        addi x28, x0, 100
        add  x29, x28, x0
        beq  x29, x28, bf_taken
        addi x27, x0, 999
bf_taken:
        addi x27, x0, 14

# Multiple consecutive branches
multi_branch:
        addi x30, x0, 0
        beq  x0, x0, mb1
        addi x30, x0, 999
mb1:
        beq  x0, x0, mb2
        addi x30, x0, 888
mb2:
        beq  x0, x0, mb3
        addi x30, x0, 777
mb3:
        addi x30, x0, 15

end:
        wfi