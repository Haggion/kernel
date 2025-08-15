.section .text

.equ APB_CLK, 0x84

.equ SSPCR0,       0x000 # control register 0
.equ SPPCR1,       0x004 # control register 1
.equ SSPDR,        0x008 # receive FIFO and transmit FIFO data register
.equ SSPSR,        0x00C # status register
.equ SSPCPSR,      0x010 # clock prescale register
.equ SSPIMSC,      0x014 # interrupt mask set/clear register
.equ SSPRIS,       0x018 # raw interrupt status register
.equ SSPMIS,       0x01C # masked interrupt status register
.equ SSPICR,       0x020 # interrupt clear register
.equ SSPDMACR,     0x024 # DMA control register
.equ SSPPeriphID0, 0xFE0 # peripheral identification register bits 7:0
.equ SSPPeriphID1, 0xFE4 # peripheral identification register bits 15:8
.equ SSPPeriphID2, 0xFE8 # peripheral identification register bits 23:16
.equ SSPPeriphID3, 0xFEC # peripheral identification register bits 31:24
.equ SSPPCellID0,  0xFF0 # primecell identification register bits 7:0
.equ SSPPCellID1,  0xFF4 # primecell identification register bits 15:8
.equ SSPPCellID2,  0xFF8 # primecell identification register bits 23:16
.equ SSPPCellID3,  0xFFC # primecell identification register bits 31:24

/* SSPCR0 | Control register 0
===========================================================
Bits  Name  Type  Function
15:8  SCR   RW    Serial clock rate
7     SPH   RW    SSPCLKOUT phase
6     SPO   RW    SSPCLKOUT polarity
5:4   FRF   RW    Frame format:
                  00 = Motorola SPI frame format
                  01 = TI synchronous serial frame format
                  10 = National Microwave frame format
                  11 = Reserved
3:0   DSS   RW    Data size select:
                  0000:0010 = Reserved
                  0011 = 4-bit
                  0100 = 5-bit
                  0101 = 6-bit
                  0110 = 7-bit
                  0111 = 8-bit
                  1000 = 9-bit
                  1001 = 10-bit
                  1010 = 11-bit
                  1011 = 12-bit
                  1100 = 13-bit
                  1101 = 14-bit
                  1110 = 15-bit
                  1111 = 16-bit */

/* SSPCR1 | Control register 1
===========================================================
Bits  Name  Type  Function
15:4  N/A   N/A   Reserved
3     SOD   RW    Slave-mode output disable
2     MS    RW    Master or slave mode select. 
                  SSP must be disabled (SSE=0) to change.
                  0 = device configured as master
                  1 = device configured as slave
1     SSE   RW    Synchronous serial port enable:
                  0 = SSP operation disabled
                  1 = SSP operation enabled
0     LBM   RW    Loop back mode:
                  0 = normal serial port operation enabled
                  1 = output of transmit serial shifter is connected
                      to input of receive serial shifter internally */

/* SSPDR | Data register
===========================================================
Bits  Name  Type  Function
15:0  DATA  RW    Transmit/receive FIFO:
                  Read = receive
                  Write = transmit
                  When SSP is programmed for data size
                  less than 16 bits (DSS,)
                  data needs to be right-justified. */

/* SSPSR | Status register
Indicates FIFO fill status & SSP busy status
===========================================================
Bits  Name  Type  Function
15:5  N/A   N/A   Reserved
4     BSY   R     SSP busy flag:
                  0 = idle
                  1 = busy
3     RFF   R     Receive FIFO full:
                  0 = not full
                  1 = full
2     RNE   R     Receive FIFO not empty:
                  0 = empty
                  1 = not empty
1     TNF   R     Transmit FIFO not full:
                  0 = full
                  1 = not full
0     TFE   R     Transmit FIFO empty:
                  0 = not empty
                  1 = empty */

/* SSPCPSR | Clock prescale register
Specifies division factor by which the input SSPCLK
must be internally divided before further use.
Must be an even number between 2 and 254
===========================================================
Bits  Name     Type  Function
15:8  N/A      N/A   Reserved
7:0   CPSDVSR  RW    Clock prescale divisor */

/* SSPIMSC | Interrupt mask set/clear register
===========================================================
Bits  Name  Type  Function
15:4  N/A    N/A   Reserved
3     TXIM   RW    Transmit FIFO interrupt mask
2     RXIM   RW    Receive FIFO interrupt mask
1     RTIM   RW    Receive timeout interrupt mask
0     RORIM  RW    Receive overrun interrupt mask */

/* SSPRIS | Raw interrupt status register
Gives the current raw status value of the 
corresponding interrupt prior to masking
===========================================================
Bits  Name    Type  Function
15:4  N/A     N/A   Reserved
3     TXRIS   R     Gives raw interrupt state of SSPTXINTR interrupt
2     RXRIS   R     Gives raw interrupt state of SSPRXINTR interrupt
1     RTRIS   R     Gives raw interrupt state of SSPRTINTR interrupt
0     RORRIS  R     Gives raw interrupt state of SSPRORINTR interrupt */

/* SSPMIS | Masked interrupt status register
Gives the current masked status value of the
corresponding interrupt
===========================================================
Bits  Name    Type  Function
15:4  N/A     N/A   Reserved
3     TXMIS   R     Gives transmit FIFO masked interrupt state of SSPTXINTR interrupt
2     RXMIS   R     Gives receive FIFO masked interrupt state of SSPRXINTR interrupt
1     RTMIS   R     Gives receive timeout masked interrupt state of SSPRTINTR interrupt
0     RORMIS  R     Gives receive over run masked interrupt status of SSPRORINTR interrupt */

/* SSPICR | Interrupt clear register
On a write of 1, clears the corresponding interrupt
===========================================================
Bits  Name    Type  Function
15:2  N/A     N/A   Reserved
1     RTIC    W     Clears SSPRTINTR interrupt
0     RORIC   W     Clears SSPRORINTR interrupt */

/* SSPDMACR | DMA control register
===========================================================
Bits  Name    Type  Function
15:2  N/A     N/A   Reserved
1     TXDMAE  RW    If set to 1, DMA for transmit FIFO is enabled
0     RXDMAE  RW    If set to 1, DMA for receive FIFO is enabled */

/* SSPPeriphID0-3 | Peripheral indentification registers
Each register is 8-bits, and can be together treated
as a single 32-bit register, as described below:
===========================================================
PartNumber[11:0]
               Used to indentify the peripheral
DesignerID[19:12]
               Indentification of the designer
Revision[23:20]
               Revision number of the peripheral
Configuration[31:24]
               Configuration option of the peripheral */

/* SSPPCellD0-3 | PrimeCell identification registers
Used as a standard cross-peripheral identification system. */

/* Interrupts
===========================================================
SSPRXINTR
         SSP receive FIFO service interrupt request.
         Asserted when there are four or more
         valid entries in the receive FIFO
SSPTXINTR
         SSP transmit FIFO service interrupt request.
         Asserted when there are four or less valid
         entries in the transmit FIFO
SSPRORINTR
         SSP receive overrun interrupt request.
         Asserted when FIFO is already full and an
         additional data frame is received
SSPRTINTR
         SSP time out interrupt request.
         Asserted when the receive FIFO is not empty
         and the SSP has remained idle for a fixed
         32-bit period
SSPINTR
         Interrupts are combined into a single output SSPINTR.
         Asserted if any of the four indiviual interrupts
         it is comprised of are asserted and enabled */


.global enable_pl022_spi
enable_pl022_spi:
   # save return address
   addi sp, sp, -16
   sd ra, 8(sp)

   li   a0, APB_CLK
   call starfive_enable_sysclock
   
   li   a0, 0x200
   li   a1, 0x06
   call starfive_deassert_sysreset
   #0x17

   ld ra, 8(sp)
   addi sp, sp, 16 
   ret