.section .text

.equ UART_BASE, 0x10000000
.equ LSR,       0x14
.equ W_READY,   0x20
.equ R_READY,   0x1

.global starfive_uart_put_char
.type starfive_uart_put_char, @function
# void starfive_uart_put_char(int ch)
starfive_uart_put_char:
    li t0, UART_BASE
1:
    lb t1, LSR(t0)
    # mask ready to write bit
    andi t1, t1, W_READY
    beqz t1, 1b

    sb a0, 0(t0)     # Write a0 (argument) to UART0
    ret

.global starfive_uart_get_char
.type starfive_uart_get_char, @function
# char starfive_uart_get_char()
starfive_uart_get_char:
    li t0, UART_BASE

2:
    lb t1, LSR(t0)

    # mask ready to read bit
    andi t1, t1, R_READY
    beqz t1, 2b

    lb a0, 0(t0)     # Read UART0 to a0 (ret val)
    ret
