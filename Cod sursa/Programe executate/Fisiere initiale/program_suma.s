addi t0, zero, 5
addi t2, zero, 1
add t1, t1, t2
addi t2, t2, 1
blt t2, t0, -8
addi t1, zero, 0
jalr ra, 0(zero)