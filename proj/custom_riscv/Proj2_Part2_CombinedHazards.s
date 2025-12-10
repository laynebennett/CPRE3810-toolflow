.data

.text
.globl main

main:
        addi x1,  x0, 10
        addi x2,  x0, 20
        addi x3,  x0, 10
        lui  x20, 0x10010
        sw   x1, 0(x20)
        sw   x2, 4(x20)

# Load-use then branch
test1:
        lw   x10, 0(x20)
        beq  x10, x1, t1_taken
        addi x11, x0, 999
t1_taken:
        addi x11, x0, 1

# Forward then branch
test2:
        add  x12, x1, x2
        beq  x12, x12, t2_taken
        addi x13, x0, 999
t2_taken:
        addi x13, x0, 2

# Load-use with forwarding
test3:
        add  x14, x1, x2
        lw   x15, 0(x20)
        add  x16, x15, x14

# Multiple forwarding paths
test4:
        add  x17, x1, x2
        add  x18, x2, x3
        add  x19, x18, x17

# Branch after load-use
test5:
        lw   x21, 4(x20)
        add  x22, x21, x0
        beq  x22, x2, t5_taken
        addi x23, x0, 999
t5_taken:
        addi x23, x0, 5

# Store with forwarding
test6:
        add  x24, x1, x2
        add  x25, x2, x3
        sw   x25, 8(x20)

# Load -> use -> branch -> use
test7:
        lw   x26, 0(x20)
        add  x27, x26, x1
        beq  x27, x2, t7_taken
        addi x28, x0, 999
t7_taken:
        add  x28, x27, x0

# Back-to-back loads
test8:
        lw   x29, 0(x20)
        lw   x30, 4(x20)
        add  x31, x29, x30

# Loop with load-use
test9:
        addi x5, x0, 0
        addi x6, x0, 3
loop9:
        lw   x7, 0(x20)
        add  x5, x5, x7
        blt  x5, x6, skip9
        beq  x0, x0, done9
skip9:
        beq  x0, x0, loop9
done9:

# JAL with forwarding
test10:
        add  x8, x1, x2
        jal  x9, jal10_target
        addi x8, x0, 999
jal10_target:
        add  x10, x8, x0

# JALR
test11:
        la   x11, jalr11_target
        jalr x12, 0(x11)
        addi x13, x0, 999
jalr11_target:
        addi x13, x0, 11

# Stress test
test12:
        add  x14, x1, x2
        add  x15, x14, x1
        lw   x16, 0(x20)
        add  x17, x16, x15
        beq  x17, x17, t12_done
        addi x18, x0, 999
t12_done:
        addi x18, x0, 12

end:
        wfi