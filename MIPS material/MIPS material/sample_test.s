# TEST code for SPim
#
# Originally by Jongmin Lee
# Modified by Haejin Nam


	.data # data section
saved_ret_pc:	.word 0		# Holds PC to return from main
values: .word 0, 150 

	.text # text(instruction) section
main:
	sw      $31, saved_ret_pc
    la      $t2, values
    lw      $t0, 4($t2)
    lw      $t1, 0($t2)
loop:
    add     $t1, $t1, $t0
	sub     $t0, $t0, 1
	beqz    $t0, final
	b       loop
final:

	.data 
result:  .asciiz "\n result value is : "

	.text
	li      $v0, 4	    # syscall 4 (print_str)
	la      $a0, result
	syscall
	li      $v0, 1
	move    $a0, $t1    # syscall 1 (print_int)
	syscall
	lw      $31, saved_ret_pc
	jr      $31		    # Return from main
                        # Return to the default code (loader) of the simulator
                        # It will invoke an exit system call
