--  The driver handler package exposes abstract interfaces to drivers,
--  allowing the rest of the code to be unconcerned with choosing an
--  implementation.

with System.Unsigned_Types; use System.Unsigned_Types;
with Callables; use Callables;
with File_System;

package Driver_Handler is
   type UART_Implementations is (
      QEMU, StarFive, OpenSBI, None
   );
   type Power_Implementations is (
      OpenSBI, QEMU, None
   );
   type RTC_Implementations is (
      StarFive, QEMU, None
   );
   type Graphics_Implementations is (
      UBoot, QEMU, None
   );
   type CC_Implementations is (
      StarFive, None
   );
   type Storage_Implementations is (
      Hoshen, None
   );

   UART_Implementation : UART_Implementations;
   Power_Implementation : Power_Implementations;
   RTC_Implementation : RTC_Implementations;
   Graphics_Implementation : Graphics_Implementations;
   CC_Implementation : CC_Implementations;
   Storage_Implementation : Storage_Implementations;

   procedure Init;
   pragma Export (Ada, Init, "_initialize_drivers");
   procedure Init_Graphics;

   --  UART drivers
   procedure UART_Put_Char (Ch : Integer);
   pragma Export (Ada, UART_Put_Char, "uart_put_char");
   function UART_Get_Char return Character;
   pragma Export (Ada, UART_Get_Char, "uart_get_char");

   --  power drivers
   procedure Shutdown;
   pragma Export (Ada, Shutdown, "shutdown");
   procedure Reboot;
   pragma Export (Ada, Reboot, "reboot");

   --  RTC drivers
   function RTC_Seconds return Integer;
   pragma Export (Ada, RTC_Seconds, "rtc_seconds");
   function RTC_Minutes return Integer;
   pragma Export (Ada, RTC_Minutes, "rtc_minutes");
   function RTC_Hours return Integer;
   pragma Export (Ada, RTC_Hours, "rtc_hours");
   function RTC_Day return Integer;
   pragma Export (Ada, RTC_Day, "rtc_day");
   function RTC_Month return Integer;
   pragma Export (Ada, RTC_Month, "rtc_month");
   function RTC_Year return Integer;
   pragma Export (Ada, RTC_Year, "rtc_year");
   procedure Enable_RTC;
   pragma Export (Ada, Enable_RTC, "enable_rtc");

   --  graphics drivers
   Draw_Pixel        : CA_III;
   Draw_2_Pixels     : CA_IIII;
   Draw_2_Pixels_Raw : CA_UII;
   Draw_4_Pixels     : CA_IIUll;

   function Screen_Width return Integer;
   pragma Export (Ada, Screen_Width, "screen_width");
   function Screen_Height return Integer;
   pragma Export (Ada, Screen_Height, "screen_height");
   function Stride return Integer;
   pragma Export (Ada, Stride, "stride");
   function Bytes_Per_Pixel return Integer;
   pragma Export (Ada, Bytes_Per_Pixel, "bytes_per_pixel");
   function Framebuffer_Start return Long_Long_Unsigned;
   pragma Export (Ada, Framebuffer_Start, "framebuffer_start");
   procedure Enable_Graphics;
   pragma Export (Ada, Enable_Graphics, "enable_graphics");

   type Pixel_Format is (
      RG16, XR24, None
   );

   function DRM_Pixel_Format return Pixel_Format;
   pragma Export (Ada, DRM_Pixel_Format, "pixel_format");

   type Graphic_Features is record
      Draw_Pixel : Boolean;
      Draw_2_Pixels : Boolean;
      Draw_4_Pixels : Boolean;
   end record;

   function Graphics_Supports return Graphic_Features;
   pragma Export (Ada, Graphics_Supports, "graphics_supports");

   --  cache control drivers
   procedure Flush_Address (Address : Long_Long_Unsigned);
   pragma Export (Ada, Flush_Address, "flush_address");

   --  storage drivers
   function Read_Block (Address : Unsigned) return File_System.Block_Bytes;
   pragma Export (C, Read_Block, "read_block");
   procedure Write_Block (Address : Unsigned; Data : File_System.Block_Bytes);
   pragma Export (C, Write_Block, "write_block");
private
   --  UART drivers
   procedure QEMU_UART_Put_Char (Ch : Integer);
   pragma Import (Ada, QEMU_UART_Put_Char, "qemu_uart_put_char");
   function QEMU_UART_Get_Char return Character;
   pragma Import (Ada, QEMU_UART_Get_Char, "qemu_uart_get_char");

   procedure StarFive_UART_Put_Char (Ch : Integer);
   pragma Import (Ada, StarFive_UART_Put_Char, "starfive_uart_put_char");
   function StarFive_UART_Get_Char return Character;
   pragma Import (Ada, StarFive_UART_Get_Char, "starfive_uart_get_char");

   procedure OpenSBI_DBCN_Put_Char (Ch : Integer);
   pragma Import (Ada, OpenSBI_DBCN_Put_Char, "opensbi_dbcn_write_byte");
   function OpenSBI_DBCN_Get_Char return Character;
   pragma Import (Ada, OpenSBI_DBCN_Get_Char, "opensbi_dbcn_read_byte");

   --  power drivers
   procedure OpenSBI_Shutdown;
   pragma Import (Ada, OpenSBI_Shutdown, "opensbi_shutdown");
   procedure OpenSBI_Reboot;
   pragma Import (Ada, OpenSBI_Reboot, "opensbi_reboot");

   procedure QEMU_Shutdown;
   pragma Import (Ada, QEMU_Shutdown, "qemu_shutdown");
   procedure QEMU_Reboot;
   pragma Import (Ada, QEMU_Reboot, "qemu_reboot");

   --  RTC drivers
   function StarFive_RTC_Seconds return Integer;
   pragma Import (Ada, StarFive_RTC_Seconds, "starfive_rtc_seconds");
   function StarFive_RTC_Minutes return Integer;
   pragma Import (Ada, StarFive_RTC_Minutes, "starfive_rtc_minutes");
   function StarFive_RTC_Hours return Integer;
   pragma Import (Ada, StarFive_RTC_Hours, "starfive_rtc_hours");
   function StarFive_RTC_Day return Integer;
   pragma Import (Ada, StarFive_RTC_Day, "starfive_rtc_day");
   function StarFive_RTC_Month return Integer;
   pragma Import (Ada, StarFive_RTC_Month, "starfive_rtc_month");
   function StarFive_RTC_Year return Integer;
   pragma Import (Ada, StarFive_RTC_Year, "starfive_rtc_year");
   procedure StarFive_Enable_RTC;
   pragma Import (Ada, StarFive_Enable_RTC, "starfive_enable_rtc");

   function QEMU_Goldfish_RTC_Seconds return Integer;
   pragma Import (Ada, QEMU_Goldfish_RTC_Seconds, "qemu_goldfish_rtc_seconds");
   function QEMU_Goldfish_RTC_Minutes return Integer;
   pragma Import (Ada, QEMU_Goldfish_RTC_Minutes, "qemu_goldfish_rtc_minutes");
   function QEMU_Goldfish_RTC_Hours return Integer;
   pragma Import (Ada, QEMU_Goldfish_RTC_Hours, "qemu_goldfish_rtc_hours");
   function QEMU_Goldfish_RTC_Day return Integer;
   pragma Import (Ada, QEMU_Goldfish_RTC_Day, "qemu_goldfish_rtc_day");
   function QEMU_Goldfish_RTC_Month return Integer;
   pragma Import (Ada, QEMU_Goldfish_RTC_Month, "qemu_goldfish_rtc_month");
   function QEMU_Goldfish_RTC_Year return Integer;
   pragma Import (Ada, QEMU_Goldfish_RTC_Year, "qemu_goldfish_rtc_year");

   --  graphics drivers
   procedure UBoot_FB_Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Integer
   );
   pragma Import (Ada, UBoot_FB_Draw_Pixel, "uboot_fb_draw_pixel");
   procedure UBoot_FB_Draw_4_Pixels (
      X : Integer;
      Y : Integer;
      Colors : Long_Long_Unsigned
   );
   pragma Import (Ada, UBoot_FB_Draw_4_Pixels, "uboot_fb_draw_4_pixels");
   function UBoot_FB_Width return Integer;
   pragma Import (Ada, UBoot_FB_Width, "uboot_fb_width");
   function UBoot_FB_Height return Integer;
   pragma Import (Ada, UBoot_FB_Height, "uboot_fb_height");
   function UBoot_FB_Stride return Integer;
   pragma Import (Ada, UBoot_FB_Stride, "uboot_fb_stride");
   function UBoot_FB_BPP return Integer;
   pragma Import (Ada, UBoot_FB_BPP, "uboot_fb_bpp");
   function UBoot_FB_Start return Long_Long_Unsigned;
   pragma Import (Ada, UBoot_FB_Start, "uboot_fb_start");

   --  cache control drivers
   procedure StarFive_Flush_Address (Address : Long_Long_Unsigned);
   pragma Import (Ada, StarFive_Flush_Address, "starfive_flush_address");
end Driver_Handler;