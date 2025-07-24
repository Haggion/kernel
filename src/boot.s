.section .text
.global _start
.type _start, @function

_start:
	la sp, _stack_top # set stack pointer to top of stack
	la a0, _kernel_entry
	jalr a0

# infinite loop as fallback
1:
	wfi
	j 1b
