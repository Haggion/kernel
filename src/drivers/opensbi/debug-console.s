.section  .bss
.align    1
read_data:
   .space 1

.section .text

.equ CONSOLE_EID,    0x4442434E

.equ WRITE_FID,      0
.equ READ_FID,       1
# write is for one or more bytes, write_byte is for just one
.equ WRITE_BYTE_FID, 2

.global opensbi_dbcn_write_byte
.type opensbi_dbcn_write_byte, @function
# void opensbi_dbcn_write_byte (char)
opensbi_dbcn_write_byte:
   li a7, CONSOLE_EID
   li a6, WRITE_BYTE_FID
   ecall
   ret

.global opensbi_dbcn_read_byte
.type opensbi_dbcn_read_byte, @function
# char opensbi_dbcn_read_byte
opensbi_dbcn_read_byte:
1: li a7, CONSOLE_EID
   li a6, READ_FID

   li a0, 1 # num bytes
   la a1, read_data
   li a2, 0

   # clear data so we don't read back
   # what was pressed previously
   li t0, 0
   sb t0, 0(a1)

   ecall

   bnez a0, 1b

   la t0, read_data
   lb a0, 0(t0)

   # loop until input given
   beqz a0, 1b

   ret
