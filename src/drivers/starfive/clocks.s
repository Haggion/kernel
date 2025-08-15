.section .text

.equ CLK_ENABLE, 0x80000000

.equ SYSCRG,     0x13020000
.equ AONCRG,     0x17000000

.extern _uart_put_cstring

.global starfive_enable_clock
.type starfive_enable_clock, @function
# void enable_clock (address)
starfive_enable_clock:
   lw t0, 0(a0)
   li t1, CLK_ENABLE
   or t0, t0, t1
   sw t0, 0(a0)

   ret

.global starfive_check_clock
.type starfive_check_clock, @function
# void starfive_check_clock (address, output_on_fail)
starfive_check_clock:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   lw t0, 0(a0)
   li t1, CLK_ENABLE
   and t0, t0, t1

   bnez t0, 1f

   mv a0, a1
   call _uart_put_cstring

1: ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_enable_sysclock
.type starfive_enable_sysclock, @function
starfive_enable_sysclock:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   li   t0, SYSCRG
   add  a0, a0, t0
   call starfive_enable_clock

   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_enable_aonclock
.type starfive_enable_aonclock, @function
starfive_enable_aonclock:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   li   t0, AONCRG
   add  a0, a0, t0
   call starfive_enable_clock

   ld ra, 8(sp)
   addi sp, sp, 16 
   ret
