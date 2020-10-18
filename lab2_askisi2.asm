#lab 2 askisi 2

.data
str:    .space 20 # allazei prin tin xrisi
sub_str: .space 8 # allazei prin tin xrisi
string_msg: .asciiz "Please  give string: "
substring_msg: .asciiz "Please give substring: "
final_msg: .asciiz "The max substring has length: "
keno: .asciiz "\n"

.text
.globl main

.macro read_string (%x)
li $v0, 8
la $a0,%x
li $a1,20         #allazei prin tin xrisi
syscall
.end_macro

.macro read_sub (%x)
li $v0, 8
la $a0,%x
li $a1,8       #allazei prin tin xrisi
syscall
.end_macro

.macro print_int (%x)
li $v0, 1
add $a0, $zero, %x
syscall
.end_macro

.macro print_msg (%x)
li $v0, 4
la $a0,%x
syscall
.end_macro

main:
add $s0,$0,$0
add $s1,$0,$0
add $t0,$0,$0

print_msg(string_msg)
read_string(str)
move $s0,$a0

print_msg(keno)
print_msg(substring_msg)
read_sub(sub_str)
move $s1,$a0

#la $a0,$s0
#la $a1,$s1
jal substring
add  $t0,$a3,$zero

print_msg(keno)
print_msg(final_msg)
print_int($t0)

end:
li $v0,10
syscall

substring:

add	$t1,$zero,$zero # topiko max
add	$s3,$zero,$zero # max 
addi    $t2,$zero,20 #allagi prin thn xrisi

move  $t0,$s1 
lw  $t3, 0($t0)		

loop:
lw  $t4,0($s0) 
bne $t4, $t3, option	# if $t0 != $t1 then target
subi $t2, $t2, 1
beq $t2,$zero,exit_substring
addi $s0,$s0,4
addi $t0,$t0,4
addi $t1, $t1, 1
lw  $t3, 0($t0)		 
blt $t1, $s3, loop	
add $s3,$zero,$t1
j loop

option:
move  $t0,$s1 
lw $t3, 0($t0)
subi $t2, $t2, 1
beq $t2,$zero,exit_substring
addi $s0,$s0,4
j loop

exit_substring:
move $a3,$s3
jr $ra
