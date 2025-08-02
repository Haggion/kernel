.section .text

.global shutdown
.type shutdown, @function
shutdown:
   li a7, 0x53525354       # SBI extension ID for system reset ('SRST')
   li a6, 0                # Function ID 0 = system shutdown
   li a0, 0                # Shutdown type (0 = shutdown)
   li a1, 0                # Reserved
   ecall                  # Invoke SBI
