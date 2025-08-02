.section .text

.global xhci_register
.type xhci_register, @function
# int xhci_register(int offset)
# returns the value of an xhci register at the provided offset
xhci_register:
   # save argument
   mv t0, a0

   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get mmio addr and use to retrieve register
   call xhci_mmio
   add a0, a0, t0
   lbu a0, 0(a0)

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret
