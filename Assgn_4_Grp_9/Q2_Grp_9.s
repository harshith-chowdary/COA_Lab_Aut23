# COA LAB 16-08-2023 Wednesday

# Assignment Number : 4			Problem Number    : 2
# Group Number      : 9			Semester          : AUTUMN 2023
# Group Members     : 
# ===> Meduri Harshith Chowdary (21CS10042)
# ===> Maddi Nihith (21CS10040)

### DATA

.data
    prompt: 
        .asciiz "Input an integer n : "
    result: 
        .asciiz "Number of steps from "
    mid:
        .asciiz " to 1 are : "
	endofprog:
		.asciiz " !!\n"
    invalid:
        .asciiz "\nInvalid input !!"

### CODE
.text

main:
    # show prompt
    li        $v0, 4
    la        $a0, prompt
    syscall

    # read x
    li        $v0, 5
    syscall

    # storing input value
    move $t4, $v0

    ble $v0, $zero, cornercase  # For invalid input of number x
    move      $a0, $v0

    jal      series       # jump series and save position to $ra
    move      $t0, $v0        # $t0 = $v0

    # show prompt
    li        $v0, 4
    la        $a0, result
    syscall

    # show input n
    li $v0, 1
    move $a0, $t4
    syscall

    # show prompt
    li        $v0, 4
    la        $a0, mid
    syscall

    # print the result
    li        $v0, 1        # system call #1 - print int
    move      $a0, $t0        # $a0 = $t0
    syscall                # execute
    
    # show prompt
    li        $v0, 4
    la        $a0, endofprog
    syscall

    # return 0
    j exit

cornercase:
    # Print the result
    li $v0, 4           # syscall code 4 for printing a string
    la $a0, invalid  # load the result message string address
    syscall

exit:
    # Exit the program
    li $v0, 10          # syscall code 10 for program exit
    syscall

.text

even:
    # current n is even => next recursion is called on n/2
    li $t3, 2       
    div $a0, $t3

    mflo $a0

    # jump to label after i.e., from where this is called
    j after

series:
    # base case -- still in parent's stack segment
    # adjust stack pointer to store return address and argument
    
    addi    $sp, $sp, -8
    
    # save $s0 and $ra
    sw      $s0, 4($sp)
    sw      $ra, 0($sp)

    # base case : when n is 1 return 0
    li $t1, 1
    bne     $a0, $t1, else
    move    $v0, $zero    # return 0
    j series_return

else:
    # backup $a0
    move    $s0, $a0

    li $t2, 1
    and $s0, $s0, $t2       # checking the parity of current n

    beq $s0, $zero, even    # if n is even, n -> n/2 and jump to after

    # if n is odd, n -> 3*n + 1
    addi $t2, $t2, 2        
    mult $a0, $t2

    mflo $a0
    addi $a0, $a0, 1

    after:
    jal     series
   
    # when we get here, we already have Series(x-1) store in $v0
    addu    $v0, $v0, 1

series_return:
    lw      $s0, 4($sp)
    lw      $ra, 0($sp)
    addi    $sp, $sp, 8
    jr      $ra
