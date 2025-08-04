.section .text

.equ NONE,     0
.equ QEMU,     1
.equ STARFIVE, 2
.equ OPENSBI,  3
.equ UBOOT,    4

.global default_uart
.type default_uart, @function
default_uart:
   li a0, QEMU
   ret

.global default_rtc
.type default_rtc, @function
default_rtc:
   li a0, NONE
   ret

.global default_power
.type default_power, @function
default_power:
   li a0, NONE
   ret

.global default_graphics
.type default_graphics, @function
default_graphics:
   la a0, NONE
   ret