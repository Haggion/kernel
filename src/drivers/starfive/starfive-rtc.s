.section .text

.equ RTC_BASE, 0x17040000
.equ CLK_CTRL, 0x17000000

# rtc offsets
.equ RTC_IRQ_EN,     0x10
.equ RTC_IRQ_EVENT,  0x14
.equ RTC_IRQ_STATUS, 0x18
.equ RTC_TIME,       0x3C
.equ RTC_DATE,       0x40

# unused, but could be useful later
.equ RTC_ACT_TIME,   0x34
.equ RTC_ACT_DATE,   0x38
.equ RTC_SW_CAL_VAL, 0x04
.equ RTC_HW_CAL_CFG, 0x08
.equ RTC_CMP_CFG,    0x0C
.equ RTC_CAL_VAL,    0x24
.equ RTC_CFG_TIME,   0x28
.equ RTC_CFG_DATE,   0x2C
.equ RTC_TIME_LATCH, 0x44
.equ RTC_DATE_LATCH, 0x48

# clock controller offsets
.equ CLK_APB,        0x28
.equ CLK_CALC,       0x34
.equ CLK_MUX,        0x30
.equ RST_STATUS,     0x3C
.equ RST_SET,        0x38

# bitmasks
.equ SECONDS_MASK,    0x7F
.equ MINUTES_MASK,    0x3F
.equ HOURS_MASK,      0x7F
.equ DAY_MASK,        0x3F
.equ MONTH_MASK,      0x7C0
.equ YEAR_MASK,       0xFF800
.equ RTC_IRQ_1SEC,    (1 << 3)
.equ RTC_ENABLED,     0x1
.equ RTC_24HR_MODE,   (1 << 3)
.equ RTC_IRQ_ENABLED, 0x10
.equ CLK_ENABLE,      0x80000000

# shifts
.equ SECONDS_SHIFT, 0
.equ MINUTES_SHIFT, 7
.equ HOURS_SHIFT,   14


rtc_time:
   # trigger irq event
   li   t5, RTC_BASE
   li   t1, RTC_IRQ_1SEC
   addi t0, t5, RTC_IRQ_EVENT
   sw   t1, 0(t0)

   # clear irq status
   sw t1, RTC_IRQ_STATUS(t5)

   # wait for response
1: lw   t2, RTC_IRQ_STATUS(t5)
   andi t2, t2, RTC_IRQ_1SEC
   beqz t2, 1b

   # read the time
   lw a0, RTC_TIME(t5)
2: ret

rtc_date:
   # trigger irq event
   li   t5, RTC_BASE
   li   t1, RTC_IRQ_1SEC
   addi t0, t5, RTC_IRQ_EVENT
   sw   t1, 0(t0)

   # clear irq status
   sw t1, RTC_IRQ_STATUS(t5)

   # wait for response
1: lw   t2, RTC_IRQ_STATUS(t5)
   andi t2, t2, RTC_IRQ_1SEC
   beqz t2, 1b

   # read the date
   lw a0, RTC_DATE(t5)
2: ret

bcd_to_binary:
   # (bcd & 0xF) + ((bcd >> 4) * 10)
   andi t0, a0, 0xF
   srli t1, a0, 4
   li t2, 10
   mul t1, t1, t2
   add a0, t0, t1
   ret

.global starfive_rtc_seconds
.type starfive_rtc_seconds, @function
starfive_rtc_seconds:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get time
   call rtc_time
   # mask seconds
   andi a0, a0, SECONDS_MASK

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_rtc_minutes
.type starfive_rtc_minutes, @function
starfive_rtc_minutes:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get time
   call rtc_time
   # shift past seconds
   srli a0, a0, MINUTES_SHIFT
   # mask minutes
   andi a0, a0, MINUTES_MASK

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret
   
.global starfive_rtc_hours
.type starfive_rtc_hours, @function
starfive_rtc_hours:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get time
   call rtc_time
   # shift past minutes
   srli a0, a0, HOURS_SHIFT
   # mask hours
   andi a0, a0, HOURS_MASK

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_rtc_day
.type starfive_rtc_day, @function
starfive_rtc_day:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get date
   call rtc_date
   # mask days
   andi a0, a0, DAY_MASK

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_rtc_month
.type starfive_rtc_month, @function
starfive_rtc_month:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get date
   call rtc_date
   # mask months
   andi a0, a0, MONTH_MASK

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.global starfive_rtc_year
.type starfive_rtc_year, @function
starfive_rtc_year:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get date
   call rtc_date
   # mask years
   li t0, YEAR_MASK
   and a0, a0, t0

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.extern _put_cstring
.extern _put_int

.global starfive_enable_rtc
.type starfive_enable_rtc, @function
starfive_enable_rtc:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   call deassert_reset

   la a0, enabling_apb
   call _put_cstring
   # enable APB clock
   li   t0, CLK_CTRL + CLK_APB
   lw   a0, 0(t0)
   li t1, CLK_ENABLE
   or a0, a0, t1
   ori  a0, a0, (1<<5)
   sw a0, 0(t0)

   # check if enable was successful
   lw a0, 0(t0)
   and a0, a0, t1
   bnez a0, 4f
   la a0, failed_set_apb
   call _put_cstring
4:
   la a0, enabling_calc
   call _put_cstring
   # enable RTC calculator gate
   li   t0, CLK_CTRL + CLK_CALC
   li   t1, CLK_ENABLE
   lw   t2, 0(t0)
   or  t2, t2, t1
   sw   t2, 0(t0)

   # check if enable was successful
   lw t2, 0(t0)
   and t2, t2, t1
   bnez t2, 3f
   la a0, failed_set_calc
   call _put_cstring

3:
   # check that mux has correct selection
   la a0, check_mux
   call _put_cstring
   li t0, CLK_CTRL + CLK_MUX
   lw a0, 0(t0)
   call _put_int
   la a0, newline
   call _put_cstring

   beqz a0, 2f
   la a0, wrong_mux
   call _put_cstring
2:
   # check value of RTC enabled bit
   la a0, check_rtc_status
   call _put_cstring
   li t0, RTC_BASE
   lw a0, 0(t0)
   andi a0, a0, RTC_ENABLED
   call _put_int
   la a0, newline
   call _put_cstring

   # enable RTC
   la a0, enabling_rtc
   call _put_cstring

   li t0, RTC_BASE

   lw t1, 0(t0)
   ori t1, t1, RTC_ENABLED
   ori t1, t1, RTC_24HR_MODE
   sw t1, 0(t0)

   # recheck value of RTC enabled bit
   li t0, RTC_BASE
   lw a0, 0(t0)
   andi a0, a0, RTC_ENABLED
   bnez a0, 1f
   la a0, rtc_failed_enable
   call _put_cstring
1:
   # enable RTC IRQ
   addi t0, t0, RTC_IRQ_ENABLED
   lw t1, 0(t0)
   ori t1, t1, RTC_IRQ_1SEC
   sw t1, 0(t0)
   la a0, irq_enable
   call _put_cstring

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

deassert_reset:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # read status of assert pins
   la a0, asserting_status
   call _put_cstring
   li t0, CLK_CTRL + RST_STATUS
   lw a0, 0(t0)
   call _put_int
   la a0, newline
   call _put_cstring

   # deassert reset registers
   la a0, asserting_reset
   call _put_cstring
   li   t0, CLK_CTRL + RST_SET
   lw   t1, 0(t0)
   andi t1, t1, ~((1 << 5) | (1 << 6) | (1 << 7))
   sw   t1, 0(t0)

   # recheck status of assert pins
   la a0, asserting_status
   call _put_cstring
   li t0, CLK_CTRL + RST_STATUS
   lw a0, 0(t0)
   call _put_int
   la a0, newline
   call _put_cstring

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

.section .rodata
enabling_rtc:       .asciz "[RTC] Enabling StarFive RTC\n\r"
check_rtc_status:   .asciz "[RTC] StarFive RTC enabled bit has has value of "
newline:            .asciz "\n\r"
rtc_failed_enable:  .asciz "\x1b[31m[RTC] Failed to enable StarFive RTC\x1b[0m\n\r"
asserting_reset:    .asciz "[RTC] Asserting reset pins 5, 6, and 7\n\r"
asserting_status:   .asciz "[RTC] Status of reset is: "
check_apb_enabled:  .asciz "[RTC] APB clock enabled status (should be 1): "
check_mux:          .asciz "[RTC] MUX selection (should be 0): "
wrong_mux:          .asciz "\x1b[31m[RTC] Mux has incorrect selection\x1b[0m\n\r"
failed_set_calc:    .asciz "\x1b[31m[RTC] Failed to enable RTC calculator gate\x1b[0m\n\r"
failed_set_apb:     .asciz "\x1b[31m[RTC] Failed to enable RTC APB clock\x1b[0m\n\r"
failed_set_control: .asciz "\x1b[31m[RTC] Failed to set clock control register\x1b[0m\n\r"
enabling_calc:      .asciz "[RTC] Enabling RTC calculator gate\n\r"
enabling_apb:       .asciz "[RTC] Enabling RTC APB clock\n\r"
enabling_ctrl:      .asciz "[RTC] Setting clock control register\n\r"
irq_enable:         .asciz "[RTC] Enabling RTC IRQ\n\r"
