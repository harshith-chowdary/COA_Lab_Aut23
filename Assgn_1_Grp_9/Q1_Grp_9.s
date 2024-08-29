# COA LAB 07-08-2023 Monday

# Assignment Number : 1			Problem Number    : 1
# Group Number      : 9			Semester          : AUTUMN 2023
# Group Members     : 
# ===> Meduri Harshith Chowdary (21CS10042)
# ===> Maddi Nihith (21CS10040)

### DATA ###

.data 
	# ascii null terminated string variables for I/O
	enter_number:
		.asciiz "Enter the number : "
	output1:
		.asciiz "\nThe e^x for given x = "
 	output2:
		.asciiz " is "
	output3:
		.asciiz "  approximately.\nTaylor series converges after "
	output4:
		.asciiz "  Iterations !!"
	newline:
		.asciiz "\n"

### CODE ###

.text
.globl main

main:
	la $a0, enter_number # Loads $a0 with the address of "enter_number"
	li $v0, 4 # Prints to prompt the user to enter
	syscall

	li $v0, 5 # Reads input integer 'x' from user
	syscall
	
	move $t7, $v0 # storing value of 'x'
	
	li $t0, 1 # initialize iterator to 1
	li $t1, 1 # initialize previous term in Taylor Series
	li $t2, 0 # initialize sum of the series to 0

loop:
	beq $t1, $zero, exit_loop # Check if the next term is 0, if yes breaks the loop

	add $t2, $t2, $t1 # add the next term to sum of the series
	
	mul $t1, $t1, $t7 # calculating the next power of input 'x'
	div $t1, $t0

	mflo $t1
	
	addi $t0, $t0, 1 # incrementing the iterator

	b loop # looping over loop

exit_loop:
	
	# Prints the output
	la $a0, output1 
	li $v0, 4 
	syscall

	# Prints the value of 'x'
	move $a0, $t7 
	li $v0, 1
	syscall

	la $a0, output2
	li $v0, 4
	syscall

	# Prints the value of e^x
	move $a0, $t2 
	li $v0, 1
	syscall
	
	la $a0, output3
	li $v0, 4
	syscall

	# Prints the number of Iterations before convergence
	add $t0, $t0, -1
	move $a0, $t0
	li $v0, 1
	syscall

	la $a0, output4
	li $v0, 4
	syscall

exit:

	# Exit Call
	li $v0, 10
	syscall