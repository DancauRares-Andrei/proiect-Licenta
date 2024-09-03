auipc ra, 0
jal ra, 12
addi zero, zero, 0
jal ra, 40
addi sp, sp, -4
sw ra, 0(sp)
addi a0, zero, 5
addi a1, zero, 3
addi a0, a0, 2
add a0, a0, a1
lw ra, 0(sp)
addi sp, sp, 4
jalr t0, 0(ra)
addi zero, zero, 0
jalr ra, 0(zero)