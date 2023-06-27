addi $a0, $zero, 4

func: 
addi $sp, $sp, -4
sw $s0, 0($sp)
add $s0, $zero, $a0 
addi $v0, $zero, 1 

func_loop:	
beq $s0, $zero, func_return 
add $v0, $v0, $s0 
addi $s0, $s0, -1 
j func_loop 

func_return:
lw $s0, 0($sp)
add $sp, $sp, 4

add $a0, $v0, $zero
li $v0, 1
syscall
li $v0, 10 # exit service
syscall
