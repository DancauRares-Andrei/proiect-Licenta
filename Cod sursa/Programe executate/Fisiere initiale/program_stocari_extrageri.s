addi ra, zero, -1 
addi gp, zero, 1
sb ra, 0(zero)
sub ra, ra, gp
sh ra, 4(zero)
sub ra, ra, gp
sd ra, 8(zero)
bltu gp, ra, 8
add zero, zero, zero
bgeu ra, gp, 8
add zero, zero, zero
lb a0, 0(zero)
ld a1, 8(zero)
lh a2, 4(zero)
lbu a3, 15(zero)
lhu a4, 0(zero)
lwu a5, 4(zero)
jalr ra, 0(zero)
