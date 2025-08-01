.section .text

.global uart_put_char
.type uart_put_char, @function
# void uart_put_char(int ch)
uart_put_char:
    li t0, 0x10000000
1:
    # 0x10000014 is line status register
    li t1, 0x10000014
    lb t1, (t1)
    # mask ready to write bit
    andi t1, t1, 0x20
    beqz t1, 1b

    sb a0, 0(t0)     # Write a0 (argument) to UART0
    ret

.global uart_get_char
.type uart_get_char, @function
# char uart_get_char()
uart_get_char:
    li t0, 0x10000000

2:
    # 0x10000014 is line status register
    li t1, 0x10000014
    lb t1, (t1)
    # mask ready to read bit
    andi t1, t1, 0x1
    beqz t1, 2b

    lb a0, 0(t0)     # Read UART0 to a0 (ret val)
    ret