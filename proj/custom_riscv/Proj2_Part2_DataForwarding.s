.data

.text
.globl main

main:
        addi x1,  x0, 10
        addi x2,  x0, 20
        addi x3,  x0, 30
        addi x4,  x0, 40
        addi x5,  x0, 50
        lui  x20, 0x10010

# EX-to-EX Forwarding (1 cycle apart)
        add  x10, x1, x2
        add  x11, x10, x3

        add  x12, x1, x3
        add  x13, x4, x12

        add  x14, x1, x2
        add  x15, x14, x14

# MEM-to-EX Forwarding (2 cycles apart)
        add  x16, x1, x2
        add  x6, x3, x4
        add  x17, x16, x5

        add  x18, x2, x3
        add  x7, x4, x5
        add  x19, x1, x18

        add  x21, x1, x1
        add  x8, x2, x2
        add  x22, x21, x21

# Double Forwarding - MEM priority over WB
        add  x23, x1, x2
        add  x23, x3, x4
        add  x24, x23, x0

# I-type forwarding
        addi x25, x1, 100
        add  x26, x25, x2

        addi x27, x0, 5
        addi x28, x27, 10
        addi x29, x28, 20
        addi x30, x29, 30

# Comparison forwarding
        addi x9, x0, 100
        slt  x10, x1, x9
        add  x11, x10, x10

# Shift forwarding
        addi x12, x0, 4
        sll  x13, x1, x12
        add  x14, x13, x0

# Logical forwarding
        addi x15, x0, 0xFF
        and  x16, x15, x1
        or   x17, x16, x2
        xor  x18, x17, x3

# Store with forwarding
        addi x19, x0, 0xAB
        sw   x19, 0(x20)

        addi x21, x0, 0xCD
        add  x22, x21, x0
        sw   x22, 4(x20)

# Load then independent then use
        lw   x23, 0(x20)
        add  x24, x1, x2
        add  x25, x23, x0

end:
        wfi