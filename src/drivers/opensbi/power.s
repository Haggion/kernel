.section .text

.equ SYS_RST,  0x53525354
.equ SHUTDOWN, 0x0
.equ REBOOT,   0x2

.global opensbi_shutdown
.type opensbi_shutdown, @function
opensbi_shutdown:
   li a7, SYS_RST  # SBI extension
   li a6, 0        # function ID
   li a0, SHUTDOWN # type
   li a1, 0        # reserved
   ecall

.global opensbi_reboot
.type opensbi_reboot, @function
opensbi_reboot:
   li a7, SYS_RST  # SBI extension
   li a6, 0        # function ID
   li a0, REBOOT   # type
   li a1, 0        # reserved
   ecall
