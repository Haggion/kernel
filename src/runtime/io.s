.section .text

.global putchar
.type putchar, @function
# void putchar(int ch)
putchar:
    # UART0 (QEMU) := 0x10000000
    li t0, 0x10000000
    sb a0, 0(t0)     # Write a0 (argument) to UART0
    ret

.global getchar
.type getchar, @function
# char getchar()
getchar:
    # UART0 (QEMU) := 0x10000000
    li t0, 0x10000000
    lb a0, 0(t0)     # Read UART0 to a0 (ret val)
    ret

.global dataready
.type dataready, @function
# byte dataready() - if ret val == 0: not ready; else: ready
dataready:
    # Line status register (UART0 + 0x5)
    li t0, 0x10000005
    lb t0, (t0)
    andi a0, t0, 1 # Read first bit to check if data is ready to be read
    ret
