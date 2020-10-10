#askisi 1 lab1 

.data
success_msg: .asciiz "Number is a Power of 2"
failure_msg: .asciiz "Number is a Not a Power of 2"

.text
.globl main

main:
add $s0,$0,$0
li $v0,5
syscall	
move $t0, $v0 
addi $t1,$s0,2

for:
bgt $t1,$t0,failure
beq $t1,$t0,success
sll $t1,$t1,1
j for

failure:
li $v0,4
la $a0,failure_msg
syscall
j end

success:
li $v0,4
la $a0,success_msg
syscall

end:
li $v0,10
syscall
