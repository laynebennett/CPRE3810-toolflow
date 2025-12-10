 .data

.text
.globl main

############################################################
#Proj2_Part1_TestInstructions.s 
#  Software pipeline test
#  - Uses all instructions
#  - Test simple 5 stage pipeline with NO forwarding/stalls.
############################################################

main:
############################################################
# 0) Initialize registers (only read from x0 here)
############################################################
        addi x1,  x0, 10        # sources for ALU
        addi x2,  x0, 20
        addi x3,  x0, -5

        addi x20, x0, 0x100     # data memory
        addi x21, x0, -1        # 0xFFFFFFFF for loads
        lui  x20, 0x10010
        
        addi x27, x0, 5         # branches
        addi x28, x0, 5
        addi x29, x0, 7

        lui  x18, 0x12345       # test LUI

        auipc x19, 0x1         
        
        # Gap to avoid RAW hazard AUIPC
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP

        addi x19, x19, 16       

        addi x0, x0, 0          # NOP

############################################################
# 1) ALU Test (R-type + I-type) 
############################################################
        # Producers
	add  x4, x1, x2
	addi x5, x1, 5
	sub  x6, x2, x1

        # Gap to allow x4/x6 to be written
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP

        # Consumers of x4/x6
        and  x7, x4, x6         
        andi x8, x6, 0x00FF     

        or   x9,  x4, x6        
        xor  x11, x4, x6        

        # Gap before using x9 / x11
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP

        ori  x10, x9, 1         # uses x9
        xori x12, x11, 0x0F0    # uses x11

        # Comparisons (only depend on x1/x2 which are long-settled)
        slt  x13, x1, x2        # slt  (1)
        slti x14, x1, 15        # slti (1)
        sltiu x15, x1, 15       # sltiu (1)

        addi x0, x0, 0          # NOP

        sll  x16, x1, x13       # shift left by 1
        slli x17, x1, 2         # slli

        # Gap before using x16 in shifts
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP

        srl  x22, x16, x13      # srl by 1
        srli x23, x16, 1        # srli
        sra  x24, x16, x13      # sra by 1
        srai x25, x16, 1        # srai

        # Extra NOPs to separate ALU and memory tests
        addi x0, x0, 0
        addi x0, x0, 0
        addi x0, x0, 0

############################################################
# 2) Memory operations: sw, lw, lb, lh, lbu, lhu
############################################################
        sw   x21, 0(x20)        # MEM[0x10010000] = 0xFFFFFFFF
        
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        
        lw   x21, 0(x20)        
        lb   x5,  0(x20)        
        lh   x6,  0(x20)        
        lbu  x7,  0(x20)        
        lhu  x8,  0(x20)        

        addi x0, x0, 0
        addi x0, x0, 0

############################################################
# 3) Branch instructions: beq, bne, blt, bge, bltu, bgeu
#    x27=5, x28=5, x29=7 were already set so no data hazards.
############################################################

beq_test:
        beq  x27, x28, beq_taken     # taken (5 == 5)
        addi x0, x0, 0               # delay slot 1 (NOP)
        addi x0, x0, 0               # delay slot 2 (NOP)

beq_taken:
        bne  x27, x29, bne_taken     # taken (5 != 7)
        addi x0, x0, 0
        addi x0, x0, 0

bne_taken:
        blt  x27, x29, blt_taken     # taken (5 < 7)
        addi x0, x0, 0
        addi x0, x0, 0

blt_taken:
        bge  x29, x27, bge_taken     # taken (7 >= 5)
        addi x0, x0, 0
        addi x0, x0, 0

bge_taken:
        bltu x27, x29, bltu_taken    # taken (unsigned 5 < 7)
        addi x0, x0, 0
        addi x0, x0, 0

bltu_taken:
        bgeu x29, x27, bgeu_taken    # taken (unsigned 7 >= 5)
        addi x0, x0, 0
        addi x0, x0, 0

bgeu_taken:
        addi x0, x0, 0               # spacer
        addi x0, x0, 0

############################################################
# 4) JAL and JALR
#    - JAL jumps forward to jal_target.
#    - JALR jumps to jalr_target using an address built by LUI+ADDI.
############################################################

        jal  x31, jal_target         # uses ResultSrc="10", PCSel="01"
        addi x0, x0, 0               # delay NOPs
        addi x0, x0, 0               # delay NOPs

jal_target:
        # Build absolute address of jalr_target into x30.
        lui  x30, %hi(jalr_target)   # producer of x30

        # Gap to avoid RAW hazard
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP

        addi x30, x30, %lo(jalr_target)

        # Avoiding RAW hazard ADDI -> JALR
        addi x0, x0, 0               # NOP
        addi x0, x0, 0               # NOP
        addi x0, x0, 0               # NOP

        jalr x0, 0(x30)              # jump to jalr_target
        addi x0, x0, 0               # delay NOPs
        addi x0, x0, 0               # delay NOPs

jalr_target:
############################################################
# 5) HALT
############################################################                       
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
        addi x0, x0, 0          # NOP
end:
    wfi       
