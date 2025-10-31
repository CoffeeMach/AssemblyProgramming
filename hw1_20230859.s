# PROGRAM: First Assignment

# Registers used in the assignment:
# $s0 = number of nodes N
# $s1 = root pointer of BST
# $s2 = heap pointer (pointing to the next free node)
# $s3 = loop counter
# $s5 = current node in post_order

.data		# Data declaration section

.align 2                  # to make heap 4-byte aligned
heap_space: .space 12000	# 1000 nodes * 12 bytes

.text
.globl main
main:
  la $s2, heap_space
  li $v0, 5	                # reads integer
  syscall
  move $s0, $v0

  li $s1, 0	                # root pointer is NULL
  li $s3, 0	                # loop counter is 0

# step1: Read input and build BST
read_loop:
  bge $s3, $s0, end_read    # if i >= N, then terminate loop

  li $v0, 5
  syscall
  move $a0, $v0	            # move to $a0 for new_node

  # create new node
  jal new_node	            # return node pointer in $v0
  move $a1, $v0	            # $a1 holds the new node for insertion (pointer to new node)

  # insert iteratively
  move $a0, $s1             # current root is $a0
  jal insert_iter	          # return new root in $v0
  move $s1, $v0	            # update the root with the return value

  addi $s3, $s3, 1	        # increment the loop counter i
  b read_loop

end_read:
  move $a0, $s1	    # pass root pointer to $a0
  jal post_order

  li $v0, 10	    	# syscall: exit
  syscall

# step2: Allocate new node in heap
new_node:
  move $v0, $s2	        # return pointer to new node
  sw $a0, 0($v0)	      # store key at offset 0
  sw $zero, 4($v0)	    # store 0 at offset 4 (left = NULL)
  sw $zero, 8($v0)	    # store 0 at offset 8 (right = NULL)
  addi $s2, $s2, 12	    # node size = 12 bytes (key + left + right)
  jr $ra			        	# return

# step3: Insert node iteratively into BST
insert_iter:
  beq $a0, $zero, insert_root_null  # empty tree -> new node becomes root

  move $t0, $a0                     # current node
  move $t1, $a1                     # new node

insert_loop:
  lw $t2, 0($t1)                # new key
  lw $t3, 0($t0)                # current key

  slt $t4, $t2, $t3             # $t4 = 1 if new key < current key
  bne $t4, $zero, go_left       # if new key < current key then go left subtree

  lw $t5, 8($t0)		            # $t5 = current -> right
  beq $t5, $zero, patch_right  	# if right child of current node is NULL, attach new node here
  move $t0, $t5
  b insert_loop

go_left:
  lw $t5, 4($t0)                 # $t5 = current -> left
  beq $t5, $zero, patch_left     # if left child of current node is NULL, attach new node here
  move $t0, $t5
  b insert_loop

patch_left:
  sw $t1, 4($t0)    # attach new node as left child
  move $v0, $a0     # return original root pointer
  jr $ra

patch_right:
  sw $t1, 8($t0)    # attach new node as right child
  move $v0, $a0
  jr $ra

insert_root_null:
  move $v0, $a1	    # store new node pointer in $v0
  jr $ra

# step4: post_order traversal and print
post_order:
  beq $a0, $zero, post_order_return 	# if node is NULL, just return

  addi $sp, $sp, -8	                  # save $ra and $s5 on stack, as recursion will overwrite them
  sw $ra, 4($sp)
  sw $s5, 0($sp)

  move $s5, $a0                       # to keep current pointer safe store temporarily

  # traverse left
  lw $a0, 4($s5)	                # $a0 = node -> left
  jal post_order

  # traverse right
  lw $a0, 8($s5)	                # $a0 = node -> right
  jal post_order

  # print key of current node
  lw $a0, 0($s5)	                # $a0 = node -> key
  li $v0, 1		                    # print integer in MIPS
  syscall

  li $v0, 11
  li $a0, 10
  syscall

  lw $s5, 0($sp)                  # restore current node
  lw $ra, 4($sp)	                # restore register
  addi $sp, $sp, 8

post_order_return:
  jr $ra
# BLANK LINE AT THE END TO KEEP SPIM HAPPY (as you wish...)
