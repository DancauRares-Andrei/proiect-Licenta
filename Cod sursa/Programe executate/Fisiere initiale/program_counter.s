addi t1, zero, 10
addi t2, zero, 1
sub t1, t1, t2
bne t1, zero, -4
jalr ra, 0(zero)