.section .text

.global xhci_mmio
.type xhci_mmio, @function
# address xhci_mmio()
xhci_mmio:
   li a0, 0x30000000
   ret
