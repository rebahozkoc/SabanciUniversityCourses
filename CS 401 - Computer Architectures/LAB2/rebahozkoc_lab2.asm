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
      
      
     
DiffElement:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
      	sw $a0, 4($sp) #a0 = arr
      	sw $a1, 8($sp) #a1 = tempArr
      	li $t0, 0 # i = 0 (loop variable)
      	li $t1, 0 # t1 = 0 (distinct count)
      	li $t2, 10 # arr length is always 10

diffOutWhile: 
	beq $t0, $t2, endDiffOutWhile
	li $t3, 0 # j = 0 (inner loop variable)
	li $t4, 1 # is_distinct = true

diffInWhile:
	beq $t3, $t1, endDiffInWhile
	add $t5, $t0, $t0
	add $t5, $t5, $t5 # t5 = i * 4
	add $t5, $t5, $a0 # set $t5 to address of array[i]
	
	lw $t6, 0($t5) # get array[i] and assign to $t6
	
	add $t5, $t3, $t3
	add $t5, $t5, $t5 # set t5 to j*4
	add $t5, $t5, $a1 # set t5 to address of tempArray[j]
	
	lw $t7, 0($t5) # get tempArray[j] and assign to $t7
	
	bne $t6, $t7, stillDistinct # if arr[i] != tempArr[j] is_distinct = false
	li $t4, 0 
	j endDiffInWhile
stillDistinct:
	addi $t3, $t3, 1 # j += 1
	j diffInWhile
	
endDiffInWhile:
	beq $t4, 0, skipAddElement #if is_distinct add new element and distinct +=1
	add $t5, $t0, $t0
	add $t5, $t5, $t5 # t5 = i * 4
	add $t5, $t5, $a0 # set $t5 to address of array[i]
	
	lw $t6, 0($t5) # get array[i] and assign to $t6
		
	add $t5, $t1, $t1  # Set $t5 to distinct*4
	add $t5, $t5, $t5
	add $t5, $t5, $a1 # set t5 to address of tempArray[distinct]
	
	sw $t6, 0($t5) # tempArr[distinct] = array[i]
	addi $t1, $t1, 1 # distinct += 1
	
skipAddElement:
	addi $t0, $t0, 1 # i += 1 (add 1 actualy but i goes 4 by 4)
	j diffOutWhile
	
	
endDiffOutWhile:
	move $v0, $t1
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	    

SumofElements:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
      	sw $a0, 4($sp) # a0 = arr1
      	sw $a1, 8($sp) # a1 = s0
      	sw $a2, 12($sp) # a2 = arr2
      	sw $a3, 16($sp) # a3 = s1
      	
      	li $t0, 0 # i = 0 (loop variable)
      	li $t1, 0 # t1 = 0 (sum)
      	
sumOutWhile:
	beq $t0, $a1, endSumOutWhile # i == s0
	li $t2, 0 # j = 0

	
sumInWhile:
	beq $t2, $a3, endSumInWhile # j == s1

	add $t3, $t0, $t0
	add $t3, $t3, $t3 # t3 = i * 4
	add $t3, $t3, $a0 # t3 = address of arr1[i]
	
	lw $t4, 0($t3) # t4 = arr[i]
	
	add $t3, $t2, $t2
	add $t3, $t3, $t3 # t3 = j * 4
	add $t3, $t3, $a2 # t3 = address of arr2[j]
	
	lw $t5, 0($t3) # t5 = arr[j]
	
	bne $t4, $t5, skipAddSum
	add $t1, $t1, $t4 # sum += arr1[i]

	j endSumInWhile # break the loop when a matching element is found
	
skipAddSum:
	addi $t2, $t2, 1 # j += 1
	j sumInWhile

endSumInWhile:
	addi $t0, $t0, 1 # i += 1
	j sumOutWhile

endSumOutWhile:
	
	move $v0, $t1
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
      	lw $a3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	    
