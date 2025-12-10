.data

.text
.globl main

main:
        addi x1,  x0, 10
        addi x2,  x0, 20
        addi x3,  x0, 30
        lui  x20, 0x10010

        sw   x1, 0(x20)
        sw   x2, 4(x20)
        sw   x3, 8(x20)

# Load-Use on rs1
        lw   x10, 0(x20)
        add  x11, x10, x1

# Load-Use on rs2
        lw   x12, 4(x20)
        add  x13, x1, x12

# Load-Use on both
        lw   x14, 8(x20)
        add  x15, x14, x14

# Load then store
        lw   x16, 0(x20)
        sw   x16, 12(x20)

# Load then branch
        lw   x17, 0(x20)
        beq  x17, x1, branch1
        addi x18, x0, 999
branch1:
        addi x18, x0, 111

# Chain of load-use
        lw   x19, 0(x20)
        add  x21, x19, x0
        sw   x21, 16(x20)
        lw   x22, 16(x20)
        add  x23, x22, x22

# lb, lh, lbu, lhu with use
        addi x24, x0, -1
        sw   x24, 20(x20)

        lb   x25, 20(x20)
        add  x26, x25, x0

        lbu  x27, 20(x20)
        add  x28, x27, x0

        lh   x29, 20(x20)
        add  x30, x29, x0

        lhu  x31, 20(x20)
        add  x5, x31, x0

# Load to x0 - no stall
        lw   x0, 0(x20)
        add  x6, x0, x1

# Load then independent then use
        lw   x7, 4(x20)
        add  x8, x1, x2
        add  x9, x7, x0

end:
        wfi