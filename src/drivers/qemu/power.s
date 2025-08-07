.section .text

.equ SYSCON,          0x100000
.equ SHUTDOWN_SIGNAL, 0x5555
.equ REBOOT_SIGNAL,   0x7777

.global qemu_shutdown
.type qemu_shutdown, @function
qemu_shutdown:
   li t0, SYSCON

   li t1, SHUTDOWN_SIGNAL
   sh t1, 0(t0)
   ret

.global qemu_reboot
.type qemu_reboot, @function
qemu_reboot:
   li t0, SYSCON

   li t1, REBOOT_SIGNAL
   sh t1, 0(t0)
   ret
