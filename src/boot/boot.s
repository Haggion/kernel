.section .text._start

.extern _put_cstring

.global _start
.type _start, @function
_start:
	la a0, entered_start
   call _put_cstring

	la a0, set_stk
   call _put_cstring
	# set stack pointer to top of stack
	la sp, _stack_base
	
	la a0, zero_bss
   call _put_cstring
	# zero bss
	call _zero_bss
	
	la a0, init_heap
   call _put_cstring
	call initalize_heap

	la a0, checking_stk
   call _put_cstring
	# make sure stack pointer is in stack
	la t0, _stack_limit
	la t1, _stack_base
	mv t2, sp

	blt t2, t0, err_bad_stack
	bgt t2, t1, err_bad_stack

	# make sure stack is properly aligned
	andi t0, sp, 15
	bnez t0, err_misaligned_stack

	la a0, stk_ok
   call _put_cstring

	j main

main:
	la a0, enabling_rtc
   call _put_cstring
	#enable clock
	call enable_rtc

	la a0, entering_kernel
   call _put_cstring
	# start kernel
	call _kernel_entry

# infinite loop as fallback
1:
	wfi
	j 1b


.section .rodata
entered_start:   .asciz "[BOOT] Entered start\n\r"
set_stk:         .asciz "[BOOT] Setting stack pointer\n\r"
zero_bss:        .asciz "[BOOT] Zeroing bss\n\r"
init_heap:       .asciz "[BOOT] Initializing heap\n\r"
checking_stk:    .asciz "[BOOT] Checking stack\n\r"
stk_ok:          .asciz "[BOOT] Stack passed checks\n\r"
enabling_rtc:    .asciz "[BOOT] Enabling RTC\n\r"
entering_kernel: .asciz "[BOOT] Entering kernel\n\n\r"
