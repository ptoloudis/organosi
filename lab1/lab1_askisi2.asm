#askisi 2 lab1 

.data
N1_msg: .asciiz "Please give N1:"
N2_msg: .asciiz "Please give N2:"
final_1_msg: .asciiz "The max final union of ranges is ["
final_2_msg: .asciiz "]."
comma_msg: .asciiz ","

.text
.globl main

main:
add $s0,$0,$0 	# min
add $s1,$0,$0	# max
add $t0,$0,$0 	# N1'
add $t1,$0,$0	# N2'

for:
li $v0, 4	#input N1'	 
la $a0, N1_msg 
syscall
li $v0,5
syscall	
move $t0, $v0 
bltz $t0,final

li $v0, 4	#input N2'	 
la $a0, N2_msg 
syscall
li $v0,5
syscall	
move $t1, $v0

blt $t0,$s0,option_1	# if N1'<N1 
blt $s1,$t1,option_2	# if N2'<N2 

j for

option_1:
blt $t1,$s0,option_4 	#maximum interval the N2'<N1 
add $s0,$0,$t0
j for

option_2:
blt $s1,$t0,option_4	# maximum interval the N2<N1'
add $s1,$0,$t1
j for

option_4:
sub $t3,$t1,$t0
sub $t4,$s1,$s0
blt $t3,$t4,for 	# if the new space is shorter than the old
add $s0,$0,$t0
add $s1,$0,$t1
j for

final:			# print 
li $v0, 4		 
la $a0, final_1_msg   
syscall

li $v0, 1	
move $a0,$s0	
syscall

li $v0, 4		 
la $a0, comma_msg 
syscall

li $v0, 1		 
move $a0, $s1   
syscall

li $v0, 4		
la $a0, final_2_msg   
syscall

end:
li $v0,10
syscall
