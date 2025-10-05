.section .text

.equ CC_BASE,   0x2010000
.equ CC_FLUSH,  0x200

.global starfive_flush_address
.type starfive_flush_address, @function
starfive_flush_address:
   # make sure address is aligned
   andi   t0, a0, -64
   li     t1, CC_BASE + CC_FLUSH
   
   sd     t0, 0(t1)
   ret
