.section .text
.global putchar
.type putchar, @function

# void putchar(int ch)
putchar:
    # UART0 (QEMU) := 0x10000000
    li t0, 0x10000000
    sb a0, 0(t0)     # Write a0 (argument) to UART0
    ret
