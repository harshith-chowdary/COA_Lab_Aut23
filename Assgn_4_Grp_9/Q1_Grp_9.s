# COA LAB 16-08-2023 Wednesday

# Assignment Number : 4			Problem Number    : 1
# Group Number      : 9			Semester          : AUTUMN 2023
# Group Members     : 
# ===> Meduri Harshith Chowdary (21CS10042)
# ===> Maddi Nihith (21CS10040)

### DATA

.data
    prompt: 
        .asciiz "Input an integer n : "
    result: 
        .asciiz "Sum of the series  : "
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

    ble $v0, $zero, cornercase  # For invalid input of number x
    move      $a0, $v0

    jal      series       # jump series and save position to $ra
    move      $t0, $v0        # $t0 = $v0

    # show prompt
    li        $v0, 4
    la        $a0, result
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

power:
    # Loop to compute x^x
    beq $s2, $s0, adder     # if x^x is done jump after to callee => label adder

    addi $s2, $s2, 1    # incrementer 
    multu   $s1, $s0    # product till now
    mflo    $s1
    b power             # loop

series:
    # base case -- still in parent's stack segment
    # adjust stack pointer to store return address and argument
    
    addi    $sp, $sp, -8
    
    # save $s0 and $ra
    sw      $s0, 4($sp)
    sw      $ra, 0($sp)

    # base case : when n is 1 return 1
    li $t1, 1
    bne     $a0, $t1, else
    addi    $v0, $zero, 1    # return 1
    j series_return

else:
    # backup $a0
    move    $s0, $a0
    addi    $a0, $a0, -1 # x -= 1
    jal     series

    li $s2, 1           # starting with x^1 i.e., 1
    move $s1, $s0       # x^x : starting with x
    j power             # compute x^x

    adder:              
    # when we get here, we already have Series(x-1) store in $v0
    addu    $v0, $v0, $s1

series_return:
    lw      $s0, 4($sp)
    lw      $ra, 0($sp)
    addi    $sp, $sp, 8
    jr      $ra
