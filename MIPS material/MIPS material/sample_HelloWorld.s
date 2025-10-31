# PROGRAM: First Assignment

	.data		# Data declaration section

	heap_space: .space 12000	# 1000 nodes * 12 bytes

# $s1 = root pointer
# $s2 = heap pointer

main:	# Start of code section
	la $s2, heap_space		# pointer to the start of heap

	li $v0, 5	# read N
	syscall
	move $s0, $v0	# $s0 = N (number of nodes)

	li $s1, 0	# root pointer is NULL
	li $t0, 0	# loop counter is 0


# step1
read_loop:
	bge $t0, $s0, end_read		# if i >= N, then terminate loop

	li $v0, 5		# read the key
	syscall
	move $a1, $v0	# $a1 = key

	jal new_node	# return node pointer in $v0
	move $a1, $v0	# $a1 becomes node pointer

	# using $a0 as root pointer
	move $a0, $s1
	jal insert		# insert(root, key)
	move $s1, $v0	# update the root with the return value

	addi $t0, $t0, 1	# increment the loop counter i
	j read_loop
end_read:
	move $a0, $s1	# pass root pointer to $a0
	jal postOrder

	li $v0, 11		# print character in MIPS
	li $a0, 10		# print a newline (\n)
	syscall

	li $v0, 10		# syscall: exit
	syscall


#	step2
new_node:
	move $v0, $s2	# return pointer to new node
	sw $a1, 0($v0)	# store key at offset 0
	sw $zero, 4($v0)	# store 0 at offset 4 (left = NULL)
	sw $zero, 8($v0)	# store 0 at offset 8 (right = NULL)
	addi $s2, $s2, 12	# increment the heap pointer to get the next free node
	jr $ra				# return

#	step3
insert:
	beq $a0, $zero, return_new_node		# see if current root is NULL

	move $t3, $a0	# save the root pointer position

	lw $t0, 0($a0)		# load key of current root
	lw $t1, 0($a1)		# load key of new node
	slt $t2, $t1, $t0	# compare new key to root key
	beq $t2, 1, left_sub	# if new key < root key go left subtree
	j right_sub			# else

left_sub:
	lw $a0, 4($t3)	 # load left node
	jal insert		 # insert recursively
	sw $v0, 4($t3)   # root -> left is the return value
	move $v0, $t3	 # return the root
	jr $ra

right_sub:
	lw $a0, 8($t3)	 # load right node
	jal insert		 # insert recursively
	sw $v0, 8($t3)   # root -> right is the return value
	move $v0, $t3	 # return the root
	jr $ra

return_new_node:
	move $v0, $a1	# store new node pointer in $v0
	jr $ra

#	step4
postOrder:
	beq $a0, $zero, postOrder_return	# if node is NULL, just return

	addi $sp, $sp, -8	# save $ra and $a0 on stack, as recursion will overwrite them
	sw $ra, 4($sp)
	sw $a0, 0($sp)

	# traverse left
	lw $a0, 4($a0)	# $a0 = node -> left
	jal postOrder

	lw $a0, 0($sp)	# restore node pointer

	# traverse right
	lw $a0, 8($a0)	# $a0 = node -> right
	jal postOrder

	lw $a0, 0($sp)	# restore node pointer

	lw $a1, 0($a0)	 # $a1 = node -> key
	move $a0, $a1
	li $v0, 1		 # print integer in MIPS
	syscall

	li $v0, 11		 # print character in MIPS
	li $a0, 32		 # print space (" ")
	syscall

	lw $ra, 4($sp)	 # restore registers
	addi $sp, $sp, 8
	jr $ra
	
postOrder_return:
	jr $ra

# BLANK LINE AT THE END TO KEEP SPIM HAPPY AS IT SAYS IN THE EXAMPLE CODE!
