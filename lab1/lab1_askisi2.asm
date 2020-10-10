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


final:
li $v0, 4		 
la $a0, final_1_msq   
syscall
li $v0, 1		
la $a0, $s0   
syscall
li $v0, 4		 
la $a0, comma_msq  
syscall
li $v0, 1		 
la $a0, $s1   
syscall
li $v0, 4		
la $a0, final_2_msq   
syscall

end:
li $v0,10
syscall