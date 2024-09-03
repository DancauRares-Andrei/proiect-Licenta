addi a0, zero, 9
andi t0, a0, 1
beq t0, zero, 12
addi t0, zero, 999
jal t1, 8
addi t0, zero, 888
jalr ra, 0(zero)