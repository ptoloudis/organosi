#askisi 1 lab2

.data
first_msg: .asciiz "Please give size for 1:"
second_msg: .asciiz "Please give size for 2:"
num_msg: .asciiz "Please give numbers:"
final_msg: .asciiz "The final array is: " 
comma_msg: .asciiz ","
NULL_msg: .asciiz "NULL"

.text
.globl main

.macro print_int (%x)
li $v0, 1
add $a0, $zero, %x
syscall
.end_macro

.macro read_int (%x)
li $v0, 5
syscall
move %x, $v0
.end_macro

.macro print_msg (%x)
li $v0, 4
la $a0,%x
syscall
.end_macro

main:
add $s0,$0,$0 	# final out
add $s1,$0,$0 	# in1
add $s2,$0,$0 	# N
add $s3,$0,$0 	# in2
add $s4,$0,$0 	# M

print_msg (first_msg)   #read the size of in1
read_int ($s2)
add $t0,$zero,$s2
add $s1,$zero,$sp
addi $s1,$s1,-4 ###S
bne $t0,0, loop1

exit_loop1:
print_msg (second_msg)  #read the size of in2
read_int ($s4)
add $t0,$zero,$s4
add $s3,$zero,$sp
addi $s3,$s3,-4 
bne $t0,$zero,loop2

exit_loop2:         #save the argument
add $a0,$zero,$s1
add $a1,$zero,$s2
add $a2,$zero,$s3
add $a3,$zero,$s4
add $s0,$zero,$sp
addi $s0,$s0,-4 

jal merge       #go tou merge

add $t0,$a1,$a3
print_msg (final_msg)
beq $t0,0, exit1

loop3:
lw $t1,0($s0)
print_int ($t1)
addi $s0,$s0,-4
sub $t0,$t0,1
beq $t0,$zero, end
print_msg (comma_msg)
j loop3

end:
li $v0,10
syscall

exit1:
print_msg (NULL_msg)
j end

loop1:          #read and save the in1 
print_msg (num_msg)
addi $sp,$sp,-4
read_int ($t1)
sw $t1,0($sp)
sub $t0,$t0,1
bne $t0,0,loop1
j exit_loop1

loop2:          #read and save the in1
print_msg (num_msg)
addi $sp,$sp,-4
read_int ($t1)
sw $t1,0($sp)
sub $t0,$t0,1
bne $t0,0, loop2
j exit_loop2
# end main

#start merge

merge:
# lw stoixia
add $t1,$a1,$zero 	#max in1
add $t2,$a3,$zero	#max in2

add $t0,$t1,$t2 
beq $t0,0,exit_merge	#if double 0
beq $t1,$zero,if_1	    #if in1 0
beq $t2,$zero,if_2	    #if in2 0

#if double != 0
lw  $t3,0($a0)          #t5 is pointer of in1
lw  $t4,0($a2)          #t6 is pointer of in2
move $t5,$a0
move $t6,$a2

option:
blt $t3,$t4,option1     #if in1<in2
addi $sp,$sp,-4
sw $t4,0($sp)
sub $t2,$t2,1
beq $t2,$zero,if_3
addi $t6,$t6,-4
lw $t4,0($t6)
bne $t2,$zero,option
bne $t1,$zero,option2
j exit_merge 

option1:
addi $sp,$sp,-4
sw $t3,0($sp)
sub $t1,$t1,1
beq $t1,$zero,if_4
addi $t5,$t5,-4
lw $t3,0($t5)
bne $t1,$zero, option
bne $t2,$zero,option3
j exit_merge    

if_1:
lw  $t5,0($a0)
add $t3,$zero,$t5

option2:
addi $sp,$sp,-4
sw $t3,0($sp)
sub $t1,$t1,1
beq $t1,$zero,exit_merge
addi $t5,$t5,-4
lw $t3,0($t5)
bne $t1,$zero,option2
j exit_merge

if_2:
lw  $t6,0($a2)
add $t4,$zero,$t6

option3:
addi $sp,$sp,-4
sw $t4,0($sp)
sub $t2,$t2,1
beq $t2,$zero,exit_merge
addi $t6,$t6,-4
lw $t4,0($t6)
bne $t2,$zero,option3 
j exit_merge

if_3:
bne $t1,$zero,option2
j exit_merge

if_4:
bne $t2,$zero,option3

exit_merge:
jr $ra
