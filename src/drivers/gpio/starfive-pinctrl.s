.section .text

.equ GPIO_BASE, 0x13040000

.equ DOEN,          0x00
.equ DOUT,          0x40

.global starfive_pinctrl_init_pin
.type starfive_pinctrl_init_pin, @function
# void starfive_pinctrl_init_pin (pin, hi/lo)
starfive_pinctrl_init_pin:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)
   
   li   t0, 4
   div  t1, a0, t0
   mul  t1, t1, t0

   rem  t4, a0, t0
   slli t4, t4, 3

   li   t2, 0xFF
   sll  t2, t2, t4
   not  t2, t2

   # clear pin
   li   t0, GPIO_BASE + DOEN
   add  t0, t0, t1
   lw   t3, 0(t0)
   and  t3, t3, t2
   sw   t3, 0(t0)

   beqz a1, 1f
   call starfive_pinctrl_high
   j    2f
1: call starfive_pinctrl_low

2: ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_pinctrl_high
.type starfive_pinctrl_high, @function
starfive_pinctrl_high:
   li   t0, 4
   div  t1, a0, t0
   mul  t1, t1, t0

   rem  t4, a0, t0
   slli t4, t4, 3

   li   t2, 0xFF
   sll  t2, t2, t4
   not  t2, t2

   li   t0, GPIO_BASE + DOUT
   add  t0, t0, t1
   lw   t3, 0(t0)
   and  t3, t3, t2
   li   t5, 1
   sll  t5, t5, t4
   or   t3, t3, t5

   sw   t3, 0(t0)   
   ret

.global starfive_pinctrl_low
.type starfive_pinctrl_low, @function
starfive_pinctrl_low:
   li   t0, 4
   div  t1, a0, t0
   mul  t1, t1, t0

   rem  t4, a0, t0
   slli t4, t4, 3

   li   t2, 0xFF
   sll  t2, t2, t4
   not  t2, t2

   li   t0, GPIO_BASE + DOUT
   add  t0, t0, t1
   lw   t3, 0(t0)
   and  t3, t3, t2

   sw   t3, 0(t0)   
   ret

.global starfive_pinctrl_doutval
starfive_pinctrl_doutval:
    srli  t1, a0, 2 
    slli  t1, t1, 2 
    andi  t4, a0, 3
    slli  t4, t4, 3

    li    t0, GPIO_BASE + DOUT
    add   t0, t0, t1
    lw    t3, 0(t0)
    srl   t3, t3, t4
    andi  a0, t3, 1 
    ret