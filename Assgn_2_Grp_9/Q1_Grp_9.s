# COA LAB 09-08-2023 Wednesday

# Assignment Number : 2			Problem Number    : 1
# Group Number      : 9			Semester          : AUTUMN 2023
# Group Members     : 
# ===> Meduri Harshith Chowdary (21CS10042)
# ===> Maddi Nihith (21CS10040)

### DATA ###

.data
    left_str:
        .asciiz "Enter left permutation : "
    right_str:
        .asciiz "\nEnter right permutation : "
    
	out_prompt:
        .asciiz "\nProduct Permutation cycle : "

    left:
        .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    right:
        .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

    tmp:
        .space 11

    out:
        .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

### CODE ###

.text
.globl main

main:

left_in:
    la $a0, left_str
    li $v0, 4
    syscall

    la $a0, tmp
	li $a1, 11
	li $v0, 8
	syscall

    la $t0, tmp
    la $t1, left

loopl:
    lb $t2, ($t0) # load byte at $t0

	beq $t2, 0x0A, right_in
	beqz $t2, right_in

	and $t2, $t2, 0x0F
	
	sw $t2, ($t1)
    
    addi $t0, $t0, 1
    addi $t1, $t1, 4
	b loopl

right_in:
    la $a0, right_str
    li $v0, 4
    syscall

    la $a0, tmp
	li $a1, 11
	li $v0, 8
	syscall

    la $t0, tmp
    la $t1, right

loopr:
    lb $t2, ($t0) # load byte at $t0

	beq $t2, 0x0A, exe 
	beqz $t2, exe

	and $t2, $t2, 0x0F
	
	sw $t2, ($t1)
    
    addi $t0, $t0, 1
    addi $t1, $t1, 4
	b loopr

exe:
    la $t0, left   
    la $t2, out
    li $t6, 0

loop:

    lw $t3, ($t0)
    li $t4, 4
    mul $t3, $t3, $t4

    la $t1, right
    add $t1, $t1, $t3
    
    lw $t5, ($t1)

    sw $t5, ($t2)

    addi $t6, $t6, 1
    bgt $t6, 0x39, output
    addi $t0, $t0, 4
    addi $t2, $t2, 4

    b loop

output:
    la $t0, out
    li $t6, 0

    la $a0, out_prompt
    li $v0, 4
    syscall

loopo:
    bgt $t6, 0x39, exit

    lw $a0, ($t0)
    li $v0, 1
    syscall

    addi $t0, $t0, 4
    addi $t6, $t6, 1

    b loopo

exit:

	# Exit Call
	li $v0, 10
	syscall