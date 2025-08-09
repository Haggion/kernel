.section .text

.equ NONE,     0
.equ QEMU,     1
.equ STARFIVE, 2
.equ OPENSBI,  3
.equ UBOOT,    4

.global default_uart
.type default_uart, @function
default_uart:
   la a0, STARFIVE
   ret

.global default_rtc
.type default_rtc, @function
default_rtc:
   la a0, STARFIVE
   ret

.global default_power
.type default_power, @function
default_power:
   la a0, OPENSBI
   ret

.global default_graphics
.type default_graphics, @function
default_graphics:
   la a0, UBOOT
   ret

.global default_cache_controller
.type default_cache_controller, @function
default_cache_controller:
   la a0, STARFIVE
   ret
