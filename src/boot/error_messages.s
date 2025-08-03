.section .text

.extern _put_cstring

.global err_misaligned_stack
.type err_misaligned_stack, @function
err_misaligned_stack:
	la a0, misaligned_stk
	call _put_cstring
1:
	wfi
	j 1b

.global err_bad_stack
.type err_bad_stack, @function
err_bad_stack:
	la a0, misaligned_stk
	call _put_cstring
2:
	wfi
	j 2b

.section .rodata
misaligned_stk: .asciz "\x1b[31m[ERR] Misaligned stack\x1b[0m\n\r"
bad_stk:        .asciz "\x1b[31m[ERR] Stack pointer isn't in stack\x1b[0m\n\r"