.data

array1: .word 1, 1, 2, 2, 3, 3, 4, 4, 5, 5 
array2: .word 2, 2, 3, 3, 4, 4, 5, 5, 6, 6 

tempArray1: .space 40 #for storing different elements in array1
tempArray2: .space 40 #for storing different elements in array2


message: .asciiz "The sum of the same elements is "

.text


main:
	la $a0, array1 
	la $a1, tempArray1 
      	jal DiffElement  
      	move $s0, $v0 
      	
      	la $a0, array2 
	la $a1, tempArray2 
      	jal DiffElement  
     	move $s1, $v0

     	la $a0, tempArray1
     	move $a1, $s0
     	la $a2, tempArray2
     	move $a3, $s1
     	
     	jal SumofElements
     	
     	move $t0, $v0
     	
     	la $a0, message
     	li $v0, 4
     	syscall	
     	
      	move $a0, $t0  
      	li $v0,1
      	syscall
      	
      	li $v0, 10
      	syscall   
      
      
     
#DiffElement:
###############################################
#   Your code goes here
###############################################
	
	
	jr $ra
	    
     
###############################################
# Everything in between should be deleted
############################################### 


#SumofElements:
###############################################
#   Your code goes here
###############################################
	
	
	jr $ra
	    
     
###############################################
# Everything in between should be deleted
###############################################

		      
      





