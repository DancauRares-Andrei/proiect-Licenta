addi a0, zero, 5
addi a1, zero, 7
add a2, a0, a1
sw a2, 4(zero)
addi a2, a2, -12
lw a3, 4(zero)
jalr ra, 0(zero)