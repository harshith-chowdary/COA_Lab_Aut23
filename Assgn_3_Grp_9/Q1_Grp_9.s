# COA LAB 14-08-2023 Monday

# Assignment Number : 3			Problem Number    : 1
# Group Number      : 9			Semester          : AUTUMN 2023
# Group Members     : 
# ===> Meduri Harshith Chowdary (21CS10042)
# ===> Maddi Nihith (21CS10040)

### DATA

.data
	input_n:
		.asciiz "Enter the number of elements : "
	input_nos:
		.asciiz "\nEnter the array elements one by one : \n"
	newline:
		.asciiz "\n"
    output:
        .asciiz "\nThe Max Circular Subarray Sum in the given array is : "
    outputcornercase:
        .asciiz "\nInvalid input !!"

### CODE
.text

read_int:
    li $v0, 5           # syscall code 5 for reading an integer
    syscall
    move $t0, $v0       # Move the result to $t0
    jr $ra              # Return to the calling code

    # Function to print an integer
    # Arguments: $a0 = integer to print
    # Returns: none

print_int:
    li $v0, 1           # syscall code 1 for printing an integer
    syscall
    jr $ra              # Return to the calling code

    # Function to calculate the factorial of an integer
    # Arguments: $a0 = integer for which to calculate the factorial
    # Returns: $t0 = factorial of the input integer

maxCircularSum:
    li $t1, 1    # counter
    li $t2, 0    # sum of elements of the array

    li $t9, 0  # output

    li $v0, 5           # syscall code 5 for reading an integer
    syscall
    move $t0, $v0       # Move the result to $t0

    addu $t2, $t2, $t0  # add first element to sum
    move $t5, $t0     # curr_max
    move $t6, $t0     # max_sofar
    move $t7, $t0     # curr_min
    move $t8, $t0     # min_sofar

maxCircularSumloop:
    blt $t1, $t3, maxCircularSumdo   # If counter <= input integer
    j maxCircularSumend    # Jump to the end of the loop if the counter is greater than the input integer

maxCircularSumdo:
    addi $t1, $t1, 1    # increment the counter

    li $v0, 5           # syscall code 5 for reading an integer
    syscall
    move $t0, $v0       # Move the result to $t0
    addu $t2, $t2, $t0

    addu $t5, $t5, $t0  # add current element to current_max
    
    blt $t5, $t0, update_curr_max  # check if curr_max is less than current element
    after1:

    blt $t6, $t5, update_max_sofar # check if max_sofar is less than curr_max
    after2:

    addu $t7, $t7, $t0  # add current element to current_min       
    
    bgt $t7, $t0, update_curr_min  # check if curr_min is greater than current element
    after3:

    bgt $t8, $t7, update_min_sofar # check if min_sofar is greater than curr_min
    after4:

    j maxCircularSumloop  # loop again 

update_curr_max:
    move $t5, $t0   # update curr_max to current_element
    j after1        # jump to the next line of the caller line

update_max_sofar:
    move $t6, $t5   # update max_sofar to curr_max
    j after2        # jump to the next line of the caller line

update_curr_min:
    move $t7, $t0   # update curr_min to current_element
    j after3        # jump to the next line of the caller line

update_min_sofar:
    move $t8, $t7   # update min_sofar to curr_min
    j after4        # jump to the next line of the caller line

maxCircularSumend:
    beq $t8, $t2, return_max_sofar    # check if min_sofar is equal to total sum

    sub $t2, $t2, $t8                 # subtract min_sofar from total sum

    ble $t2, $t6, return_max_sofar    # check if updated sum is less than max_sofar

    move $t9, $t2                     # update the answer as updated sum

    jr $ra                            # return to main function

return_max_sofar:
    move $t9, $t6                     # if min_sofar == sum, update answer as max_sofar

    jr $ra                            # return to main function

main:
    # Print the prompt and read the input integer
    li $v0, 4           # syscall code 4 for printing a string
    la $a0, input_n    # load the input prompt string address
    syscall
    jal read_int        # Jump and link to read_int function

    ble $t0, $zero, cornercase  # For invalid input of number of array elements

    move $t3, $t0       # Move the input integer to $a0

    li $v0, 4           # syscall code 4 for printing a string
    la $a0, input_nos    # load the input prompt string address
    syscall

    jal maxCircularSum    # Jump and link to maxCircularSum function

    # Print the result
    li $v0, 4           # syscall code 4 for printing a string
    la $a0, output  # load the result message string address
    syscall

    move $a0, $t9       # Move the factorial result to $a0
    jal print_int       # Jump and link to print_int function

    b exit              # Exit the program

cornercase:
    # Print the result
    li $v0, 4           # syscall code 4 for printing a string
    la $a0, outputcornercase  # load the result message string address
    syscall

exit:
    # Exit the program
    li $v0, 10          # syscall code 10 for program exit
    syscall
