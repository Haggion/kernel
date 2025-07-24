.section .text
.global _start
.type _start, @function

_start:
	la sp, _stack_top # set stack pointer to top of stack
	
	# zero bss
	la a0, _zero_bss
	jalr a0

	# start kernel
	la a0, _kernel_entry
	jalr a0

# infinite loop as fallback
1:
	wfi
	j 1b
