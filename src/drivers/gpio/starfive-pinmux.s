.section .text

.equ SYS_BASE, 0x13040000

.equ FUNCSEL_OFF_A,       0x2A4
.equ FUNCSEL_OFF_B,       0x2AC

.equ PAD36_SHIFT,         17
.equ PAD39_SHIFT,         26
.equ PAD58_SHIFT,         15
.equ FUNC_MASK2,          0x3

.equ PADCFG_BASE,         0x120

.equ PADCFG_IE,           (1 << 0)
.equ PADCFG_PU,           (1 << 3)
.equ PADCFG_SMT,          (1 << 6)

.equ PAD_MISO,            0x24
.equ PAD_MOSI,            0x27
.equ PAD_SCK,             0x3A

.equ FUNC_SPI1_MISO,      0
.equ FUNC_SPI1_MOSI,      0
.equ FUNC_SPI1_SCK,       0

.equ SYS_GPI,   0x080

# void set_func_field(offset, shift, func)
set_func_field:
   li   t3, FUNC_MASK2
   sll  t3, t3, a1
   not  t3, t3

   li   t5, SYS_BASE
   add  a0, t5, a0
   lw   t4, 0(a0)           # read current
   and  t4, t4, t3                 # clear field
   sll  a2, a2, a1                 # val << shift
   or   t4, t4, a2                 # set
   sw   t4, 0(a0)

   ret

# int get_func_field(offset, shift)
get_func_field:
   li   t3, FUNC_MASK2
   sll  t3, t3, a1

   li   t5, SYS_BASE
   add  a0, t5, a0
   lw   t4, 0(a0)
   and  a0, t4, t3 # mask field

   srl  a0, a0, a1
   ret

# void set_padcfg(pad, value)
set_padcfg:
   slli    a0, a0, 2 # 4 * pad
   li      t1, PADCFG_BASE
   add     a0, a0, t1
   li      t1, SYS_BASE
   add     a0, a0, t1
   sw      a1, 0(a0)

   ret

# int get_padcfg(pad)
get_padcfg:
   slli    a0, a0, 2 # 4 * pad
   li      t1, PADCFG_BASE
   add     a0, a0, t1
   li      t1, SYS_BASE
   add     a0, a0, t1
   lw      a0, 0(a0)

   ret 

# void gpi_write(index, pad)
gpi_write:
   slli  t0, a0, 2
   li    t1, SYS_BASE + SYS_GPI
   add   t1, t1, t0
   sw    a1, 0(t1)
   ret

# Apply spi1-0 pinmux: set func on pads and enable MISO pad input config
.globl starfive_pinmux_apply_spi1_0
.type  starfive_pinmux_apply_spi1_0, @function
starfive_pinmux_apply_spi1_0:
   addi sp, sp, -16
   sd   ra, 8(sp)

   li   a0, 0x70
   call starfive_enable_sysclock
   li   a0, 0x00
   li   a1, 0x02
   call starfive_deassert_sysreset 

   li   t0, 0x130400B8          # SYS_IOMUX + 0x80 + 4*14
   lw   t1, 0(t0)
   li   t2, 0x7F << 16          # mask for 7-bit field
   not  t2, t2
   and  t1, t1, t2              # clear old
   li   t3, 36+2                # PAD36 -> 38 (0x26)
   slli t3, t3, 16
   or   t1, t1, t3
   sw   t1, 0(t0)

   la   a0, setting_sck
   call _put_cstring

   # SCK (PAD 58): off 0x2ac, shift 15, func = FUNC_SPI1_SCK
   li   a0, FUNCSEL_OFF_B
   li   a1, PAD58_SHIFT
   li   a2, FUNC_SPI1_SCK
   call set_func_field

   # check SCK
   li   a0, FUNCSEL_OFF_B
   li   a1, PAD58_SHIFT
   call get_func_field

   li   a2, FUNC_SPI1_SCK
   beq  a0, a2, 2f

   la   a0, sck_fail
   call _put_cstring

2: la   a0, setting_mosi
   call _put_cstring 

   # MOSI (PAD 39): off 0x2a4, shift 26, func = FUNC_SPI1_MOSI
   li   a0, FUNCSEL_OFF_A
   li   a1, PAD39_SHIFT
   li   a2, FUNC_SPI1_MOSI
   call set_func_field

   # check MOSI
   li   a0, FUNCSEL_OFF_A
   li   a1, PAD39_SHIFT
   call get_func_field
   
   li   a2, FUNC_SPI1_MOSI
   beq  a0, a2, 3f

   la   a0, mosi_fail
   call _put_cstring

3: la   a0, setting_miso
   call _put_cstring

   # MISO (PAD 36): off 0x2a4, shift 17, func = FUNC_SPI1_MISO
   li      a0, FUNCSEL_OFF_A
   li      a1, PAD36_SHIFT
   li      a2, FUNC_SPI1_MISO
   call    set_func_field

   # check MISO
   li   a0, FUNCSEL_OFF_A
   li   a1, PAD36_SHIFT
   call get_func_field
   
   li   a2, FUNC_SPI1_MISO
   beq  a0, a2, 4f

   la   a0, miso_fail
   call _put_cstring

4: la   a0, setting_padcfg
   call _put_cstring

   # PADCFG for MISO: IE | PU | SMT  (enable input, pull-up, schmitt)
   li      a0, PAD_MISO
   li      a1, PADCFG_IE | PADCFG_PU | PADCFG_SMT   # = 0x49
   call    set_padcfg

   # check that set_padcfg worked
   li   a0, PAD_MISO
   call get_padcfg
   beq  a0, a1, 1f

   la   a0, padcfg_fail
   call _put_cstring

1: ld      ra, 8(sp)
   addi    sp, sp, 16
   ret

.section .rodata
setting_padcfg: .asciz "[GPIO] Setting PADCFG for MISO (enable input | pull-up | schmitt)\n\r"
padcfg_fail:    .asciz "\x1b[31m[GPIO] Failed to set PADCFG for MISO\x1b[0m\n\r"
setting_sck:    .asciz "[GPIO] Setting SCK function field\n\r"
setting_mosi:   .asciz "[GPIO] Setting MOSI function field\n\r"
setting_miso:   .asciz "[GPIO] Setting MISO function field\n\r"
sck_fail:       .asciz "\x1b[31m[GPIO] Failed to set SCK function field\x1b[0m\n\r"
mosi_fail:      .asciz "\x1b[31m[GPIO] Failed to set MOSI function field\x1b[0m\n\r"
miso_fail:      .asciz "\x1b[31m[GPIO] Failed to set MISO function field\x1b[0m\n\r"
