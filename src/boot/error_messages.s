.section .text

.global err_misaligned_stack
.type err_misaligned_stack, @function
err_misaligned_stack:
	li t0, 0x10000000
	# 83 84 75 32 77 73 83 65 76 73 71 78 69 68 -> STK MISALIGNED
	li a0, 83
	sb a0, 0(t0)
	li a0, 84
	sb a0, 0(t0)
	li a0, 75
	sb a0, 0(t0)
	li a0, 32
	sb a0, 0(t0)
	li a0, 77
	sb a0, 0(t0)
	li a0, 73
	sb a0, 0(t0)
	li a0, 83
	sb a0, 0(t0)
	li a0, 65
	sb a0, 0(t0)
	li a0, 76
	sb a0, 0(t0)
	li a0, 73
	sb a0, 0(t0)
	li a0, 71
	sb a0, 0(t0)
	li a0, 78
	sb a0, 0(t0)
	li a0, 69
	sb a0, 0(t0)
	li a0, 68
	sb a0, 0(t0)
	li a0, 10
	sb a0, 0(t0)
	j err_misaligned_stack

.global err_bad_stack
.type err_bad_stack, @function
err_bad_stack:
	li t0, 0x10000000
   # 83 84 75 32 66 65 68 -> STK BAD
	li a0, 83
	sb a0, 0(t0)
	li a0, 84
	sb a0, 0(t0)
	li a0, 75
	sb a0, 0(t0)
	li a0, 32
	sb a0, 0(t0)
   li a0, 66
	sb a0, 0(t0)
   li a0, 65
	sb a0, 0(t0)
   li a0, 68
	sb a0, 0(t0)
   li a0, 10
	sb a0, 0(t0)
	j err_bad_stack
