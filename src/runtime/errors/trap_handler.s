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
   csrr a0, scause         # XLEN
   csrr a1, sepc           # treated as pointer-sized
   csrr a2, stval          # XLEN
   csrr a3, sstatus        # XLEN
   la   t0, _handle_trap
   jalr t0
