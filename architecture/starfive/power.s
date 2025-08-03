.section .text

.global shutdown
.type shutdown, @function
shutdown:
   li a7, 0x53525354       # SBI extension ID for system reset ('SRST')
   li a6, 0                # Function ID 0 = system shutdown
   li a0, 0                # Shutdown type (0 = shutdown)
   li a1, 0                # Reserved
   ecall                  # Invoke SBI

.global reboot
.type reboot, @function
reboot:
   li a7, 0x53525354  # SBI SRST
   li a6, 0
   li a0, 0x2           # Type: warm reboot
   li a1, 0           # Reason
   ecall
