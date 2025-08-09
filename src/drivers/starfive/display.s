.section .text

.equ FB_BASE,       0xff000000
.equ FB_WIDTH,      2256
.equ FB_HEIGHT,     1504
.equ FB_DEPTH,      16
.equ FB_STRIDE,     FB_WIDTH * 2

.equ DC_CH_BASE,    0x29400000
.equ DC_HOST_BASE,  0x29400000

.equ DC_CH0_STRIDE, 0x38
.equ DC_CH0_SIZE,   0x34
.equ DC_CH0_CTRL,   0x3C
.equ DC_CH0_ADDR,   0x30
.equ DC_CH0_START0, 0xB8
.equ DC_CH0_START1, 0xBC 
.equ DC_CH0_SWITCH, 0x00 

.equ SYSCRG_BASE,              0x13020000 # phandle 0x03
.equ VOUTCRG_BASE,             0x295C0000 # phandle 0x40

.equ SYSCRG_CLK_NOC_DISP,      0xF0
.equ SYSCRG_CLK_VOUT_SRC,      0xE8
.equ SYSCRG_CLK_TOP_VOUT_AXI,  0xF8
.equ SYSCRG_CLK_TOP_VOUT_AHB,  0xF4
.equ SYSCRG_CLK_MAGIC1,        0x28
.equ SYSCRG_CLK_MAGIC2,        0x4C
.equ SYSCRG_CLK_MAGIC3,        0x98
.equ SYSCRG_CLK_MAGIC4,        0x9C
.equ SYSCRG_CLK_MAGIC5,        0xFC

.equ VOUTCRG_CLK_PIX,          0x07 * 4 # 0x1C
.equ VOUTCRG_CLK_PIX1,         0x08 * 4 # 0x20
.equ VOUTCRG_CLK_AXI,          0x04 * 4 # 0x10
.equ VOUTCRG_CLK_CORE,         0x05 * 4 # 0x14
.equ VOUTCRG_CLK_AHB,          0x06 * 4 # 0x18
.equ VOUTCRG_CLK_TOP_LCD,      0x09 * 4 # 0x24
.equ VOUTCRG_CLK_DC,           0x01 * 4 # 0x04
.equ VOUTCRG_CLK_MAGIC1,       0x3C
.equ VOUTCRG_CLK_MAGIC2,       0x40
.equ VOUTCRG_CLK_MAGIC3,       0x44

.equ CLK_ENABLE,               0x80000000

.equ SYSCRG_RST_ASSERT0,       0x2F8
.equ SYSCRG_RST_ASSERT1,       0x2FC
.equ SYSCRG_RST_STATUS,        0x308
.equ VOUTCRG_RST_ASSERT,       0x48
.equ VOUTCRG_RST_STATUS,       0x4C

.equ SYSCRG_RST_VOUT_SRC,      1 << 0x2B
.equ SYSCRG_RST_NOC_DISP,      1 << 0x1A

.equ VOUTCRG_RST_AXI,          1 << 0x00
.equ VOUTCRG_RST_AHB,          1 << 0x01
.equ VOUTCRG_RST_CORE,         1 << 0x02

.equ SYSCRG_RST,               (SYSCRG_RST_VOUT_SRC | SYSCRG_RST_NOC_DISP)
.equ VOUTCRG_RST,              (VOUTCRG_RST_AXI | VOUTCRG_RST_AHB | VOUTCRG_RST_CORE)

#.equ SYSCRG_RST, SYSCRG_RST_NOC_DISP
#.equ VOUTCRG_RST, 0

.equ PMU_BASE,      0x17030000
.equ PMU_SW_PWRON,  0x0C
.equ PMU_TRIGGER,   0x044
.equ PMU_CUR_MODE,  0x80
.equ VOUT_PD_BIT,   (1<<4) 
.equ PMU_TRI1,      0xFF
.equ PMU_TRI2,      0x05
.equ PMU_TRI3,      0x50

.extern _uart_put_cstring
.extern _uart_put_int

# void enable_clock (address)
enable_clock:
   lw t0, 0(a0)
   li t1, CLK_ENABLE
   or t0, t0, t1
   sw t0, 0(a0)

   ret

# void check_clock (address, output_on_fail)
check_clock:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   lw t0, 0(a0)
   li t1, CLK_ENABLE
   and t0, t0, t1

   bnez t0, 1f

   mv a0, a1
   call _uart_put_cstring

   # retrieve return address
1: ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global  starfive_enable_display
.type   starfive_enable_display, @function
starfive_enable_display:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   la a0, vout_power
   call _uart_put_cstring

   li   t0, PMU_BASE + PMU_SW_PWRON
   lb   t1, 0(t0)             # read current SW_PWRON
   or   t1, t1, VOUT_PD_BIT   # set bit4
   sw   t1, 0(t0)
   fence rw, rw

   # wait until Current Power Mode reports VOUT=on
1: li   t0, PMU_BASE + PMU_CUR_MODE
   lb   t1, 0(t0)
   andi t1, t1, VOUT_PD_BIT
   beqz t1, 1b    

   # do the PMU trigger sequence
   li   t0, PMU_BASE + PMU_TRIGGER
   lb   t1, 0(t0)
   li   t2, PMU_TRI1 | PMU_TRI2 | PMU_TRI3
   or   t1, t1, t2
   sb   t1, 0(t0)

   # it seems that this is already done by U-Boot when it sets up its framebuffer
   # enable needed clocks
   la a0, clocks
   call   _uart_put_cstring
   li a0, SYSCRG_BASE + SYSCRG_CLK_NOC_DISP
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_VOUT_SRC
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_TOP_VOUT_AXI
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_TOP_VOUT_AHB
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_MAGIC1
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_MAGIC2
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_MAGIC3
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_MAGIC4
   call   enable_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_MAGIC5
   call   enable_clock

   li a0, VOUTCRG_BASE + VOUTCRG_CLK_PIX
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_PIX1
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_AXI
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_CORE
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_AHB
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_TOP_LCD
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_DC
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_MAGIC1
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_MAGIC2
   call   enable_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_MAGIC3
   call   enable_clock

   # check that all clocks got enabled
   li a0, SYSCRG_BASE + SYSCRG_CLK_NOC_DISP
   la a1, syscrg_clk_noc_disp_fail
   call   check_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_VOUT_SRC
   la a1, syscrg_clk_vout_src_fail
   call   check_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_TOP_VOUT_AXI
   la a1, syscrg_clk_top_vout_axi_fail
   call   check_clock
   li a0, SYSCRG_BASE + SYSCRG_CLK_TOP_VOUT_AHB
   la a1, syscrg_clk_top_vout_ahb_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_PIX
   la a1, voutcrg_clk_pix_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_PIX1
   la a1, voutcrg_clk_pix1_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_AXI
   la a1, voutcrg_clk_axi_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_CORE
   la a1, voutcrg_clk_core_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_AHB
   la a1, voutcrg_clk_ahb_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_TOP_LCD
   la a1, voutrg_clk_top_lcd_fail
   call   check_clock
   li a0, VOUTCRG_BASE + VOUTCRG_CLK_DC
   la a1, voutcrg_clk_dc_pix0_fail
   call   check_clock


   # deassert resets
   # check syscrg reset status
   /*
   la a0, syscrg_reset_status_lo
   call _uart_put_cstring
   li t0, SYSCRG_BASE + SYSCRG_RST_STATUS
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring
   la a0, syscrg_reset_status_hi
   call _uart_put_cstring
   li t0, SYSCRG_BASE + SYSCRG_RST_STATUS + 8
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   la a0, deasserting
   call _uart_put_cstring

   # deassert syscrg
   li   t0, SYSCRG_BASE + SYSCRG_RST_ASSERT0
   li   t2, ~SYSCRG_RST_NOC_DISP
   lw   t1, 0(t0)
   and  t2, t2, t1
   sw   t2, 0(t0)
   fence rw, rw

   li   t0, SYSCRG_BASE + SYSCRG_RST_ASSERT1
   li   t1, ~(1 << (0x2B - 32))
   lw   t2, 0(t0)
   and  t1, t1, t2
   sw   t1, 0(t0)
   fence rw, rw

   li   t0, VOUTCRG_BASE + VOUTCRG_RST_ASSERT
   li   t2, ~VOUTCRG_RST
   lw   t1, 0(t0)
   and  t2, t2, t1
   sw   t2, 0(t0)
   fence rw, rw

   # recheck syscrg reset status
   la a0, syscrg_reset_status_lo
   call _uart_put_cstring
   li t0, SYSCRG_BASE + SYSCRG_RST_STATUS
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring
   la a0, syscrg_reset_status_hi
   call _uart_put_cstring
   li t0, SYSCRG_BASE + SYSCRG_RST_STATUS + 8
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring
   */
   # try a different approach to deasserting resets:
   li t0, 0x130202FC
   li t1, 0x07E7F600
   sb t1, 0(t0)

   li t0, 0x13020308
   li t1, 0xFB9FFFFF
   sb t1, 0(t0)

   li t0, VOUTCRG_BASE + VOUTCRG_RST_ASSERT
   li t1, 0x0
   sb t1, 0(t0)

   # program DC8200 registers
   la a0, dc_regs
   call _uart_put_cstring

   # disable global switch
   la a0, disable_switch
   call _uart_put_cstring
   li   t0, DC_HOST_BASE + DC_CH0_SWITCH
   sw   x0, 0(t0)
   fence rw, rw

   # turn off ctrl so can write to registers
   la a0, disable_ctrl
   call _uart_put_cstring
   li   t0, DC_HOST_BASE + DC_CH0_CTRL
   sw   x0, 0(t0)
   fence rw, rw

   # write frame buffer base address
   la a0, fb_curr_addr
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_ADDR
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   la a0, setting_fb_addr
   call _uart_put_cstring

   li   t0, DC_CH_BASE + DC_CH0_ADDR
   li   t1, FB_BASE >> 12
   #sw   t1, 0(t0)

   fence rw, rw

   la a0, fb_curr_addr
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_ADDR
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   li   t0, DC_CH_BASE + DC_CH0_ADDR
   lw   t1, 0(t0)
   li t2, FB_BASE >> 12

   beq   t1, t2, 2f

   la a0, fb_addr_fail
   call _uart_put_cstring

   # write stride
2: la a0, fb_curr_stride
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_STRIDE
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   la a0, setting_fb_stride
   call _uart_put_cstring

   li    t0, DC_CH_BASE
   addi  t1, t0, DC_CH0_STRIDE
   li    t2, FB_STRIDE
   sw    t2, 0(t1)

   la a0, fb_curr_stride
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_STRIDE
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   # write size
   la a0, fb_curr_size
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_SIZE
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   la a0, setting_fb_size
   call _uart_put_cstring

   li    t0, DC_CH_BASE
   addi  t1, t0, DC_CH0_SIZE
   # SIZE = (V<<16)|H  → 1504×2256
   li    t2, (FB_HEIGHT<<FB_DEPTH) | FB_WIDTH
   sw    t2, 0(t1)

   la a0, fb_curr_size
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_SIZE
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   la a0, en_ch0
   call _uart_put_cstring

   la a0, fb_curr_addr
   call _uart_put_cstring
   li t0, DC_CH_BASE + DC_CH0_START0
   lw a0, 0(t0)
   call _uart_put_int
   la a0, newline
   call _uart_put_cstring

   # enable channel 0
   li   t1, DC_HOST_BASE + DC_CH0_CTRL
   # bit0 = run, bit1 = mpu_start, bit2 = cfg_mode
   li    t2, 0x7 # RUN|MPU_START|CFG_MODE
   sw    t2, 0(t1)

   lw   t2, 0(t1)
   mv   a0, t2
   call _uart_put_int

   # enable global switch
   la a0, switching
   call _uart_put_cstring

   li   t1, DC_HOST_BASE
   addi t1, t1, DC_CH0_SWITCH
   li   t2, 1         # RUN
   sw   t2, 0(t1)

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global  starfive_display_draw_pixel
.type   starfive_display_draw_pixel, @function
# void starfive_display_draw_pixel (int x, int y, int color);
starfive_display_draw_pixel:
   li   t2, FB_STRIDE
   mul  t0, a1, t2

   # x * bytes per pixel (2)
   slli t1, a0, 1
   add  t0, t0, t1

   li   t1, FB_BASE
   add  t0, t1, t0

   sh   a2, 0(t0)
   fence rw, rw
   ret

.global starfive_display_width
.type starfive_display_width, @function
starfive_display_width:
   li a0, FB_WIDTH
   ret

.global starfive_display_height
.type starfive_display_height, @function
starfive_display_height:
   li a0, FB_HEIGHT
   ret

.section .rodata
dc_regs:                      .asciz "[GRAPHICS] Programming DC8200 registers\n\r"
en_ch0:                       .asciz "[GRAPHICS] Enabling Channel 0\n\r"
deasserting:                  .asciz "[GRAPHICS] Deasserting resets\n\r"
clocks:                       .asciz "[GRAPHICS] Enabling clocks\n\r"
fb_addr_fail:                 .asciz "\x1b[31m[GRAPHICS] Failed to set DC8200 framebuffer address\x1b[0m\n\r"
setting_fb_addr:              .asciz "[GRAPHICS] Setting framebuffer address\n\r"
fb_curr_addr:                 .asciz "[GRAPHICS] Current framebuffer address: "
setting_fb_size:              .asciz "[GRAPHICS] Setting framebuffer size\n\r"
fb_curr_size:                 .asciz "[GRAPHICS] Current framebuffer size: "
setting_fb_stride:            .asciz "[GRAPHICS] Setting framebuffer stride\n\r"
fb_curr_stride:               .asciz "[GRAPHICS] Current framebuffer stride: "
switching:                    .asciz "[GRAPHICS] Enabling global switch\n\r"
disable_switch:               .asciz "[GRAPHICS] Disabling global switch\n\r"
disable_ctrl:                 .asciz "[GRAPHICS] Disabling control\n\r"
newline:                      .asciz "\n\r"
syscrg_reset_status_lo:       .asciz "[GRAPHICS] Low SYSCRG reset status is "
syscrg_reset_status_hi:       .asciz "[GRAPHICS] High SYSCRG reset status is "
voutcrg_reset_status:         .asciz "[GRAPHICS] VOUTCRG reset status is "
vout_power:                   .asciz "[GRAPHICS] Turning on power for VOUT\n\r"
# clock errors
syscrg_clk_noc_disp_fail:     .asciz "\x1b[31m[GRAPHICS] Failed to enable SYSCRG NOC_DISP clock\x1b[0m\n\r"
syscrg_clk_vout_src_fail:     .asciz "\x1b[31m[GRAPHICS] Failed to enable SYSCRG VOUT_SRC clock\x1b[0m\n\r"
syscrg_clk_top_vout_axi_fail: .asciz "\x1b[31m[GRAPHICS] Failed to enable SYSCRG TOP_VOUT_AXI clock\x1b[0m\n\r"
syscrg_clk_top_vout_ahb_fail: .asciz "\x1b[31m[GRAPHICS] Failed to enable SYSCRG TOP_VOUT_AHB clock\x1b[0m\n\r"
voutcrg_clk_pix_fail:         .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG PIX clock\x1b[0m\n\r"
voutcrg_clk_pix1_fail:        .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG PIX1 clock\x1b[0m\n\r"
voutcrg_clk_axi_fail:         .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG AXI clock\x1b[0m\n\r"
voutcrg_clk_core_fail:        .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG CORE clock\x1b[0m\n\r"
voutcrg_clk_ahb_fail:         .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG AHB clock\x1b[0m\n\r"
voutrg_clk_top_lcd_fail:      .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG TOP_LCD clock\x1b[0m\n\r"
dc_clk_pix0_fail:             .asciz "\x1b[31m[GRAPHICS] Failed to enable DC PIX0 clock\x1b[0m\n\r"
hdmi_tx0_clk_pixel_fail:      .asciz "\x1b[31m[GRAPHICS] Failed to enable HDMI TX0_PIXEL clock\x1b[0m\n\r"
voutcrg_clk_dc_pix0_fail:     .asciz "\x1b[31m[GRAPHICS] Failed to enable VOUTCRG DC8200_PIX0 clock\x1b[0m\n\r"
