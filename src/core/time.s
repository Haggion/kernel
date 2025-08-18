.section .text

.global tick_time
.type tick_time, @function
tick_time:
   rdtime a0
   ret

.global cycle_time
.type cycle_time, @function
cycle_time:
   rdcycle a0
   ret

# this value seems to be accurate
.equ TICKS_PER_US, 4

.global delay_us
.type delay_us, @function
# void delay_us (microseconds)
delay_us:
   li   t5, TICKS_PER_US

   csrr t0, time
   mul  t1, a0, t5
   add  t2, t0, t1
1: csrr t3, time
   bltu t3, t2, 1b
   
   ret

.global delay_ms
.type delay_ms, @function
delay_ms:
   # save return address
   addi sp, sp, -16
   sd   ra, 8(sp)

   li   t0, 1000
   mul  a0, a0, t0
   call delay_us

   ld   ra, 8(sp)
   addi sp, sp, 16
   ret