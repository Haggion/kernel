.equ BASE_ADDR, 0x101000

.equ TIME_LO,      0x00
.equ TIME_HI,      0x04

.equ NSEC_PER_SEC, 1000000000

.equ SECONDS_MASK, 0x3F

time:
   li t0, BASE_ADDR

   # get time, loop until
   # time is valid value (not 0 or -1)
1: lw t1, TIME_LO(t0)
   lw t2, TIME_HI(t0)

   slli t2, t2, 32
   or t1, t2, t1
   li t2, NSEC_PER_SEC
   div a0, t1, t2

   li t1, 0
   beq a0, t1, 1b
   li t1, -1
   beq a0, t1, 1b
   ret

.macro get_time_component red, mod
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)
   
   call time

   li t0, \red
   li t1, \mod

   div a0, a0, t0
   rem a0, a0, t1
   
   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret
.endm

.global qemu_goldfish_rtc_seconds
.type qemu_goldfish_rtc_seconds, @function
qemu_goldfish_rtc_seconds:
   get_time_component 1, 60

.global qemu_goldfish_rtc_minutes
.type qemu_goldfish_rtc_minutes, @function
qemu_goldfish_rtc_minutes:
   get_time_component 60, 60

.global qemu_goldfish_rtc_hours
.type qemu_goldfish_rtc_hours, @function
qemu_goldfish_rtc_hours:
   get_time_component 60 * 60, 24

.global qemu_goldfish_rtc_day
.type qemu_goldfish_rtc_day, @function
qemu_goldfish_rtc_day:
   get_time_component 60 * 60 * 24, 31

.global qemu_goldfish_rtc_month
.type qemu_goldfish_rtc_month, @function
qemu_goldfish_rtc_month:
   get_time_component 60 * 60 * 24 * 31, 12

.global qemu_goldfish_rtc_year
.type qemu_goldfish_rtc_year, @function
qemu_goldfish_rtc_year:
   get_time_component 60 * 60 * 24 * 31 * 12, 10000