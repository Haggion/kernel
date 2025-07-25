.section .text
.global _start
.type _start, @function

_start:
	# set stack pointer to top of stack
	la sp, _stack_base
	
	# zero bss
	call _zero_bss

	# make sure stack pointer is in stack
	la t0, _stack_limit
	la t1, _stack_base
	mv t2, sp

	blt t2, t0, err_bad_stack
	bgt t2, t1, err_bad_stack

	# make sure stack is properly aligned
	andi t0, sp, 15
	bnez t0, err_misaligned_stack

	j main

main:
	# start kernel
	call _kernel_entry

# infinite loop as fallback
1:
	wfi
	j 1b
