.section .text

.global putchar
.type putchar, @function
# void putchar(int ch)
putchar:
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

.global getchar
.type getchar, @function
# char getchar()
getchar:
    li t0, 0x10000000
    lb a0, 0(t0)     # Read UART0 to a0 (ret val)
    ret

.global dataready
.type dataready, @function
# byte dataready() - if ret val == 0: not ready; else: ready
dataready:
    # Line status register (UART0 + 0x14)
    li t0, 0x10000014
    lb t0, (t0)
    andi a0, t0, 1 # Read first bit to check if data is ready to be read
    ret