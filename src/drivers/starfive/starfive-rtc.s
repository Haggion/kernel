.section .text

.equ RTC_BASE,       0x17040000
.equ CLK_CTRL,       0x17000000

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
.equ CLK_APB,        0x0A * 4
.equ CLK_CALC,       0x0D * 4
.equ CLK_MUX,        0x30
.equ RST_STATUS,     0x3C
.equ RST_SET,        0x38
.equ OSC,            0x3B * 4

# bitmasks
.equ SECONDS_MASK,    0x7F
.equ MINUTES_MASK,    0x3F
.equ HOURS_MASK,      0x7F
.equ DAY_MASK,        0x3F
.equ MONTH_MASK,      0x1F
.equ YEAR_MASK,       0xFF
.equ RTC_IRQ_1SEC,    (1 << 3)
.equ RTC_ENABLED,     0x1
.equ RTC_24HR_MODE,   (1 << 3)
.equ RTC_IRQ_ENABLED, 0x10

.equ RST,             (1 << 5) | (1 << 6) | (1 << 7)

# shifts
.equ SECONDS_SHIFT,   0
.equ MINUTES_SHIFT,   7
.equ HOURS_SHIFT,     14
.equ DAY_SHIFT,       0
.equ MONTH_SHIFT,     6
.equ YEAR_SHIFT,      11

.macro get_time_or_date mask, shift, addr
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   # get time
   li   t0, RTC_BASE
   lw t0, \addr(t0)

   # shift & mask to desired value
   srli t0, t0, \shift
   andi a0, t0, \mask

   call bcd_to_binary

   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret
.endm

.macro get_time mask, shift
   get_time_or_date \mask, \shift, RTC_TIME
.endm

.macro get_date mask, shift
   get_time_or_date \mask, \shift, RTC_DATE
.endm

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
   get_time SECONDS_MASK, SECONDS_SHIFT

.global starfive_rtc_minutes
.type starfive_rtc_minutes, @function
starfive_rtc_minutes:
   get_time MINUTES_MASK, MINUTES_SHIFT
   
.global starfive_rtc_hours
.type starfive_rtc_hours, @function
starfive_rtc_hours:
   get_time HOURS_MASK, HOURS_SHIFT

.global starfive_rtc_day
.type starfive_rtc_day, @function
starfive_rtc_day:
   get_date DAY_MASK, DAY_SHIFT

.global starfive_rtc_month
.type starfive_rtc_month, @function
starfive_rtc_month:
   get_date MONTH_MASK, MONTH_SHIFT

.global starfive_rtc_year
.type starfive_rtc_year, @function
starfive_rtc_year:
   get_date YEAR_MASK, YEAR_SHIFT

.extern _put_cstring
.extern _put_int

.global starfive_enable_rtc
.type starfive_enable_rtc, @function
starfive_enable_rtc:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   call starfive_rtc_minutes
   call _put_int

   # enable APB clock
   la   a0, enabling_apb
   call _put_cstring
   li   a0, CLK_CTRL + CLK_APB
   call starfive_enable_clock

   # check if enable was successful
   li   a0, CLK_CTRL + CLK_APB
   la   a1, failed_set_apb
   call starfive_check_clock
   
   call deassert_reset

   # enable RTC
   la a0, enabling_rtc
   call _put_cstring

   li t0, RTC_BASE

   lw  t1, 0(t0)
   ori t1, t1, RTC_ENABLED
   ori t1, t1, RTC_24HR_MODE
   sw  t1, 0(t0)

   # recheck value of RTC enabled bit
   li t0, RTC_BASE
   lw a0, 0(t0)
   andi a0, a0, RTC_ENABLED
   bnez a0, 1f
   la a0, rtc_failed_enable
   call _put_cstring
1:
   # retrieve return address
   ld ra, 8(sp)
   addi sp, sp, 16 
   ret

deassert_reset:
   # save return address
   addi sp, sp, -16
   sd   ra, 8(sp)

   # read status of assert pins
   la   a0, asserting_status
   call _put_cstring
   li   t0, CLK_CTRL + RST_STATUS
   lw   a0, 0(t0)
   call _put_int
   la   a0, newline
   call _put_cstring

   # deassert reset registers
   la   a0, deasserting_reset
   call _put_cstring
   li   a0, CLK_CTRL + RST_SET
   li   a1, RST
   call starfive_deassert_reset

   # recheck status of assert pins
   la   a0, asserting_status
   call _put_cstring
   li   t0, CLK_CTRL + RST_STATUS
   lw   a0, 0(t0)
   call _put_int
   la   a0, newline
   call _put_cstring

   # retrieve return address
   ld   ra, 8(sp)
   addi sp, sp, 16 
   ret

.section .rodata
enabling_rtc:       .asciz "[RTC] Enabling StarFive RTC\n\r"
check_rtc_status:   .asciz "[RTC] StarFive RTC enabled bit has has value of "
rtc_failed_enable:  .asciz "\x1b[31m[RTC] Failed to enable StarFive RTC\x1b[0m\n\r"
deasserting_reset:  .asciz "[RTC] Deasserting reset pins 5, 6, and 7\n\r"
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
newline:            .asciz "\n\r"
