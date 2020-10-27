#askisi 1 lab3

.data
size_msg: .asciiz "Please give size:"
num_msg: .asciiz "Please give numbers:"
position_msg: .asciiz "The number is position: "
NULL_msg: .asciiz "The array is NULL"

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

#start main
main:
add $s0,$0,$0 	# size
add $s1,$0,$0 	# pinakas

print_msg (size_msg)   #read the size 
read_int ($s0)
add $t0,$zero,$s0
add $s1,$zero,$sp
addi $s1,$s1,-4 
beq $t0,0,exit_pro

loop:          #read and save 
print_msg (num_msg)
addi $sp,$sp,-4
read_int ($t1)
sw $t1,0($sp)
sub $t0,$t0,1
bne $t0,0,loop

add $a0,$zero,$s1
add $a1,$zero,$zero
addi $t0,$s0,-1
add $a2,$zero,$t0
add $a3,$zero,$s0

jal findElement
lw		$t3, 0($sp)	
addi	$sp,$sp,4	 
sll     $t0,$a3,2       
add	$sp,$sp,$t0
beq	$t3,-1,end
print_msg(position_msg)
print_int($t3) 

j end

exit_pro:
print_msg(NULL_msg)

end:
li $v0,10
syscall
#end main

#start findElement

findElement: # a0=pinakas, a1 =low ,a2=high ,a3=n

addi	$sp, $sp, -8			# $sp = sp1 -8 
sw		$a1, 4($sp)		
sw		$ra, 0($sp)

move $t4,$a0
beq		$a1, $zero, option1	# if low == 0 option1
beq		$a1, $a2, option2	# if $a1 ==a2  option2

sll     $t0,$a1,2       
sub     $t0,$a0,$t0
lw		$t1,0($t0)		# low
lw		$t2,4($t0)		# low - 1
lw      $t3,-4($t0)      # low + 1
blt		$t1, $t2, exit_option	# if $t1 < $t2 then target
blt		$t1, $t3, exit_option	# if $t3 < $t1 target
add	$t4, $zero,$a1
j exit

exit_option:
addi    $a1,$a1,1
move $a0,$t4
move $a1,$a1
move $a2,$a2
move $a3,$a3

jal findElement

lw		$t4, 0($sp)		# 
lw		$ra, 4($sp)		
lw		$a1, 8($sp)
addi    $sp,$sp,12
j exit

option1: #if low = 0
lw		$t0,0($a0)		# low
lw		$t1,-4($a0)		# low +1

blt		$t0, $t1, exit_option	# if $t0 <= $t1 then target
add	$t4, $zero,$zero
j exit


option2:
sll     $t0,$a1,2       
sub     $t0,$a0,$t0
lw		$t1,0($t0)		# low
lw		$t2,4($t0)		# low - 1
addi	$t4, $zero,-1			

blt		$t1, $t2, exit	# if $t1 <= $t2 then target
add	$t4, $zero,$a1

exit:
addi	$sp, $sp, -4			 
sw		$t4, 0($sp)	
jr $ra
