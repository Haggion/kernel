.section .text

.equ UART_BASE, 0x10000000
.equ LSR,       0x5
.equ READY,     0x1

.global qemu_uart_put_char
.type qemu_uart_put_char, @function
# void qemu_uart_put_char(int ch)
qemu_uart_put_char:
    li t0, UART_BASE
    sb a0, 0(t0)     # Write a0 (argument) to UART0
    ret

.global qemu_uart_get_char
.type qemu_uart_get_char, @function
# char qemu_uart_get_char()
qemu_uart_get_char:
    li t0, UART_BASE

2:
    lb t1, LSR(t0)
    # mask ready to read bit
    andi t1, t1, READY
    beqz t1, 2b

    lb a0, 0(t0)     # Read UART0 to a0 (ret val)
    ret
