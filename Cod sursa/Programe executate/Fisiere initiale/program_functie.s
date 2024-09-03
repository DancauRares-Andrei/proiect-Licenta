addi sp, sp, -32
sd ra, 24(sp)
sd s0, 16(sp)
addi s0, sp, 32
addi a0, zero, 2
auipc x1, 0 
jal x1, 32
sd a0, -24(s0)
addi a5, zero, 0
add a0, zero, a5
ld ra, 24(sp)
ld s0, 16(sp)
addi sp, sp, 32
jal ra, 56
addi sp, sp, -32
sd s0, 24(sp)
addi s0, sp, 32
sd a0, -24(s0)
add a4, zero, a0
add a5, zero, a4
slli a5, a5, 1
add a5, a5, a4
addi a5, a5, 1
add a0, zero, a5
ld s0, 24(sp)
addi sp, sp, 32
jal ra, -76
jalr ra, 0(zero)
