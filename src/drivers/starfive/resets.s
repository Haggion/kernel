.section .text

.global starfive_assert_reset
.type starfive_assert_reset, @function
# void starfive_assert_reset (set_addr, reset)
starfive_assert_reset:
   lw t0, 0(a0)
   or t0, t0, a1
   sw t0, 0(a0)
   ret

.global starfive_deassert_reset
.type starfive_deassert_reset, @function
# void starfive_deassert_reset (set_addr, reset)
starfive_deassert_reset:
   lw t0, 0(a0)
   not a1, a1
   and t0, t0, a1
   sw t0, 0(a0)
   ret
