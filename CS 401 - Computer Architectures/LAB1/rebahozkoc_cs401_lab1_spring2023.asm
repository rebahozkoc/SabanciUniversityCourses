.data

array1: .word 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 # final 0 indicates the end of the array; 0 is excluded; it should return TRUE for this array
array2: .word 17, 13, 11, 9, 8, 7, 5, 4, 2, 1, 0 # final 0 indicates the end of the array; 0 is excluded; it should return FALSE for this array

true: .asciiz "TRUE\n"
false: .asciiz "FALSE\n"

.text

main:
      la $a0, array2 # $a0 has the address of the A[0]
      jal lenArray  # Find the lenght of the array
      
      move $a1, $v0  # $a1 has the length of A
      
      jal Descending # void Descending(int *A, int lenA)

      bne $v0, 0, yes # if descending returns 1 print true else false
      la  $a0, false
      li  $v0, 4
      syscall
      j exit

yes:  la $a0, true
      li $v0, 4
      syscall

exit:
      li $v0, 10 # exit service
      syscall


Descending:
###############################################
#   Your code goes here
###############################################

      addi $sp, $sp, -12
      sw $ra, 8($sp) 		# save the return address
      sw $a0, 4($sp) 		# save the argument int* A
      sw $a1, 0($sp) 		# save the argument lenA
      
      slti $t0, $a1, 2 		# test if lenA < 2 (lenA <= 1)
      beq  $t0, $zero, L1 	# if lenA > 1 then go to L1
      	
      addi $v0, $zero, 1	# return 1 (true)
      addi $sp, $sp, 12		# adjust the stack pointer
      jr $ra
L1:
      lw $t0, 0($a0)		# get A[0]
      lw $t1, 4($a0)		# get A[1]
      sle $t2, $t0, $t1		# test if A[0] <= [1] if it is 1 then return false
      beq $t2, $zero, L2
      addi $v0, $zero, 0 	# A[0] <= A[1] return false
      addi $sp, $sp, 12		# adjust the stack pointer
      jr $ra
 
L2:
      addi $a0, $a0, 4		# Increase the int* A by one to get A[1]
      subi $a1, $a1, 1		# set lenA = lenA-1
      jal Descending		# recursive call result will be at $v0
      
      lw $a1, 0($sp)		# restore lenA
      lw $a0, 4($sp)		# restore int* A
      lw $ra, 8($sp)		# restore return address
      addi $sp, $sp, 12		# pop 3 items
            
###############################################
# Everything in between should be deleted
###############################################
      jr $ra	

lenArray:       #Fn returns the number of elements in an array
      addi $sp, $sp, -8
      sw $ra,0($sp)
      sw $a0,4($sp)
      li $t1, 0

laWhile:       
      lw $t2, 0($a0)
      beq $t2, $0, endLaWh
      addi $t1,$t1,1
      addi $a0, $a0, 4
      j laWhile

endLaWh:
      move $v0, $t1
      lw $ra, 0($sp)
      lw $a0, 4($sp)
      addi $sp, $sp, 8
      jr $ra
