.data

.text
.globl main

main:
        addi x1,  x0, 10
        addi x2,  x0, 20
        addi x3,  x0, -5
        addi x4,  x0, 0xFF
        lui  x20, 0x10010

# R-type ALU
        add  x5, x1, x2
        add  x6, x5, x1
        sub  x7, x6, x5
        and  x8, x4, x1
        or   x9, x8, x2
        xor  x10, x9, x1
        slt  x11, x1, x2
        sltu x12, x3, x1
        sll  x13, x1, x11
        srl  x14, x13, x11
        sra  x15, x3, x11

# I-type ALU
        addi x16, x15, 100
        andi x17, x16, 0x0F
        ori  x18, x17, 0xF0
        xori x19, x18, 0xFF
        slti x21, x19, 20
        sltiu x22, x3, 10
        slli x23, x21, 4
        srli x24, x23, 2
        srai x25, x3, 1

# LUI and AUIPC
        lui  x26, 0x12345
        addi x27, x26, 0x678
        auipc x28, 0x1
        addi x29, x28, 0

# Memory operations
        sw   x27, 0(x20)
        sw   x1, 4(x20)
        sw   x3, 8(x20)

        lw   x5, 0(x20)
        add  x6, x5, x0

        lw   x7, 4(x20)
        add  x8, x7, x7

        lb   x9, 8(x20)
        add  x10, x9, x0

        lbu  x11, 8(x20)
        add  x12, x11, x0

        lh   x13, 8(x20)
        add  x14, x13, x0

        lhu  x15, 8(x20)
        add  x16, x15, x0

        sb   x1, 12(x20)
        sh   x2, 14(x20)

# Branches
        addi x17, x0, 5
        addi x18, x0, 5
        addi x19, x0, 10

        beq  x17, x18, beq_ok
        addi x21, x0, 999
beq_ok:
        addi x21, x0, 1

        bne  x17, x19, bne_ok
        addi x22, x0, 999
bne_ok:
        addi x22, x0, 2

        blt  x17, x19, blt_ok
        addi x23, x0, 999
blt_ok:
        addi x23, x0, 3

        bge  x19, x17, bge_ok
        addi x24, x0, 999
bge_ok:
        addi x24, x0, 4

        bltu x17, x19, bltu_ok
        addi x25, x0, 999
bltu_ok:
        addi x25, x0, 5

        bgeu x19, x17, bgeu_ok
        addi x26, x0, 999
bgeu_ok:
        addi x26, x0, 6

# JAL and JALR
        jal  x27, jal_target
        addi x28, x0, 999
jal_target:
        addi x28, x0, 7

        la   x29, jalr_target
        jalr x30, 0(x29)
        addi x31, x0, 999
jalr_target:
        addi x31, x0, 8

# Loop
        addi x5, x0, 0
        addi x6, x0, 5
loop:
        addi x5, x5, 1
        blt  x5, x6, loop

# Forwarding chain
        addi x7, x0, 1
        add  x8, x7, x7
        add  x9, x8, x8
        add  x10, x9, x9
        add  x11, x10, x10
        add  x12, x11, x11

end:
        wfi