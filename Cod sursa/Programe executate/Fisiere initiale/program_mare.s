addi ra, zero, 10
addi sp, ra, 20
add gp, ra, sp
sub tp, gp, sp
lui t0, 1
addi t1, zero, 50
and t2, t0, t1
or t3, t2, t0
xor t4, t3, t2
andi t5, t4, 3
ori t6, t5, 6
xori s0, t6, 9
srli s1, s0, 2
sll s2, s1, s1
srl s3, s2, s1
slli s1, s0, 2
sw gp, 0(zero)
lw a0, 0(zero)
slt t0, sp, ra
sltu t1, gp, s1
sra t2, s0, t1
slti a3, s1, 45
sltiu s2, s3, 4
srai a5, a0, 2
sb s3, 4(zero)
sh s0, 8(zero)
sd t3, 12(zero)
lb s9, 4(zero)
lh s7, 8(zero)
lbu t5, 4(zero)
lhu s7, 8(zero)
lwu a0, 0(zero)
ld t3, 12(zero)
jal s7, 8
jalr s10, 140(a5) 
auipc s1, 20
beq sp, gp, 100
bne s1, a0, 4
blt s1, a0, 8
bge gp, a5, 4 
bltu s1, a0, 10
bgeu gp, a5, 4 
jalr ra, 0(zero)
addi zero, zero, 0
