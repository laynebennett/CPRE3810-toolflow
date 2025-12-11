.data
.text
.globl main

main:

#lui t0, 0x55555 #loads
li t0, 0x55555555 #loads
addi x0, x0, 0
addi x0, x0, 0
addi t1, t0, -0x1 #subtract 
# if the above worked, then t1 should be 55554FFF
#these are easy to check values
# this tests the loading because we know addi works (given the
#assignment constraints)
#if it didn't work we know lui did not set the initial values
wfi
