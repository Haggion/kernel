.section .text

.extern _handle_trap

.global enable_trap_handler
.type enable_trap_handler, @function
enable_trap_handler:
   la   t0, trap_entry
   csrw stvec, t0

   csrr t2, sstatus
   ori  t2, t2, (1<<1)
   csrw sstatus, t2

   ret

.align 4
trap_entry:
   # save state
   addi sp, sp, -224 # we're saving 28 registers (28 * 8 = 224)

   sd   a0, 0(sp)
   sd   a1, 0x8(sp)
   sd   a2, 0x10(sp)
   sd   a3, 0x18(sp)
   sd   a4, 0x20(sp)
   sd   a5, 0x28(sp)
   sd   a6, 0x30(sp)
   sd   a7, 0x38(sp)
   sd   t0, 0x40(sp)
   sd   t1, 0x48(sp)
   sd   t2, 0x50(sp)
   sd   t3, 0x58(sp)
   sd   t4, 0x60(sp)
   sd   t5, 0x68(sp)
   sd   t6, 0x70(sp)
   sd   s0, 0x78(sp)
   sd   s1, 0x80(sp)
   sd   s2, 0x88(sp)
   sd   s3, 0x90(sp)
   sd   s4, 0x98(sp)
   sd   s5, 0xA0(sp)
   sd   s6, 0xA8(sp)
   sd   s7, 0xB0(sp)
   sd   s8, 0xB8(sp)
   sd   s9, 0xC0(sp)
   sd   s10, 0xC8(sp)
   sd   s11, 0xD0(sp)
   sd   ra, 0xD8(sp)

   # handle trap (done in error_handler-traps.adx)
   csrr a0, scause         # XLEN
   csrr a1, sepc           # treated as pointer-sized
   csrr a2, stval          # XLEN
   csrr a3, sstatus        # XLEN

   call _handle_trap

   # retrieve state
   ld   a0, 0(sp)
   ld   a1, 0x8(sp)
   ld   a2, 0x10(sp)
   ld   a3, 0x18(sp)
   ld   a4, 0x20(sp)
   ld   a5, 0x28(sp)
   ld   a6, 0x30(sp)
   ld   a7, 0x38(sp)
   ld   t0, 0x40(sp)
   ld   t1, 0x48(sp)
   ld   t2, 0x50(sp)
   ld   t3, 0x58(sp)
   ld   t4, 0x60(sp)
   ld   t5, 0x68(sp)
   ld   t6, 0x70(sp)
   ld   s0, 0x78(sp)
   ld   s1, 0x80(sp)
   ld   s2, 0x88(sp)
   ld   s3, 0x90(sp)
   ld   s4, 0x98(sp)
   ld   s5, 0xA0(sp)
   ld   s6, 0xA8(sp)
   ld   s7, 0xB0(sp)
   ld   s8, 0xB8(sp)
   ld   s9, 0xC0(sp)
   ld   s10, 0xC8(sp)
   ld   s11, 0xD0(sp)
   ld   ra, 0xD8(sp)

   addi sp, sp, 224

   ret
