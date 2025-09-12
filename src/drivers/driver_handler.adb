--  0 => None
--  1 => QEMU
--  2 => StarFive
--  3 => OpenSBI
--  4 => UBoot

with IO;
with Terminal;
with Renderer;
with RamFB;

package body Driver_Handler is
   procedure Init is
      function UART_Default return Integer;
      pragma Import (C, UART_Default, "default_uart");
      function Power_Default return Integer;
      pragma Import (C, Power_Default, "default_power");
      function RTC_Default return Integer;
      pragma Import (C, RTC_Default, "default_rtc");
      function Graphics_Default return Integer;
      pragma Import (C, Graphics_Default, "default_graphics");
      function CC_Default return Integer;
      pragma Import (C, CC_Default, "default_cache_controller");

      UART_Selection : constant Integer := UART_Default;
      Power_Selection : constant Integer := Power_Default;
      RTC_Selection : constant Integer := RTC_Default;
      Graphics_Selection : constant Integer := Graphics_Default;
      CC_Selection : constant Integer := CC_Default;
   begin
      case UART_Selection is
         when 1 =>
            UART_Implementation := QEMU;
         when 2 =>
            UART_Implementation := StarFive;
         when 3 =>
            UART_Implementation := OpenSBI;
         when others =>
            UART_Implementation := None;
      end case;

      case Power_Selection is
         when 3 =>
            Power_Implementation := OpenSBI;
         when 1 =>
            Power_Implementation := QEMU;
         when others =>
            Power_Implementation := None;
      end case;

      case RTC_Selection is
         when 2 =>
            RTC_Implementation := StarFive;
         when 1 =>
            RTC_Implementation := QEMU;
         when others =>
            RTC_Implementation := None;
      end case;

      case Graphics_Selection is
         when 4 =>
            Graphics_Implementation := UBoot;
         when 1 =>
            Graphics_Implementation := QEMU;
         when others =>
            Graphics_Implementation := None;
      end case;

      case CC_Selection is
         when 2 =>
            CC_Implementation := StarFive;
         when others =>
            CC_Implementation := None;
      end case;

      if Graphics_Implementation /= None then
         Renderer.Initialize (Graphics_Implementation = UBoot);
         IO.Main_Stream.Output := IO.Debug;
         Terminal.Initialize;
      end if;
   end Init;

   procedure UART_Put_Char (Ch : Integer) is
   begin
      case UART_Implementation is
         when QEMU =>
            QEMU_UART_Put_Char (Ch);
         when StarFive =>
            StarFive_UART_Put_Char (Ch);
         when OpenSBI =>
            OpenSBI_DBCN_Put_Char (Ch);
         when None =>
            null;
      end case;
   end UART_Put_Char;

   function UART_Get_Char return Character is
   begin
      case UART_Implementation is
         when QEMU =>
            return QEMU_UART_Get_Char;
         when StarFive =>
            return StarFive_UART_Get_Char;
         when OpenSBI =>
            return OpenSBI_DBCN_Get_Char;
         when None =>
            return Character'Val (0);
      end case;
   end UART_Get_Char;

   procedure Shutdown is
   begin
      case Power_Implementation is
         when OpenSBI =>
            OpenSBI_Shutdown;
         when QEMU =>
            QEMU_Shutdown;
         when None =>
            null;
      end case;
   end Shutdown;

   procedure Reboot is
   begin
      case Power_Implementation is
         when OpenSBI =>
            OpenSBI_Reboot;
         when QEMU =>
            QEMU_Reboot;
         when None =>
            null;
      end case;
   end Reboot;

   function RTC_Seconds return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Seconds;
         when QEMU =>
            return QEMU_Goldfish_RTC_Seconds;
         when None =>
            return -1;
      end case;
   end RTC_Seconds;

   function RTC_Minutes return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Minutes;
         when QEMU =>
            return QEMU_Goldfish_RTC_Minutes;
         when None =>
            return -1;
      end case;
   end RTC_Minutes;

   function RTC_Hours return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Hours;
         when QEMU =>
            return QEMU_Goldfish_RTC_Hours;
         when None =>
            return -1;
      end case;
   end RTC_Hours;

   function RTC_Day return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Day;
         when QEMU =>
            return QEMU_Goldfish_RTC_Day;
         when None =>
            return -1;
      end case;
   end RTC_Day;

   function RTC_Month return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Month;
         when QEMU =>
            return QEMU_Goldfish_RTC_Month;
         when None =>
            return -1;
      end case;
   end RTC_Month;

   function RTC_Year return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Year;
         when QEMU =>
            return QEMU_Goldfish_RTC_Year;
         when None =>
            return -1;
      end case;
   end RTC_Year;

   procedure Enable_RTC is
   begin
      case RTC_Implementation is
         when StarFive =>
            StarFive_Enable_RTC;
         when others =>
            null;
      end case;
   end Enable_RTC;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Integer
   ) is
   begin
      case Graphics_Implementation is
         when UBoot =>
            UBoot_FB_Draw_Pixel (X, Y, Color);
         when QEMU =>
            RamFB.Draw_Pixel (X, Y, Color);
         when None =>
            null;
      end case;
   end Draw_Pixel;

   procedure Draw_2_Pixels (
      X_Start : Integer;
      Y       : Integer;
      Color1  : Integer;
      Color2  : Integer
   ) is
   begin
      case Graphics_Implementation is
         when QEMU =>
            RamFB.Draw_2_Pixels (X_Start, Y, Color1, Color2);
         when UBoot | None =>
            null;
      end case;
   end Draw_2_Pixels;

   procedure Draw_2_Pixels (
      Position : Unsigned;
      Color1   : Integer;
      Color2   : Integer
   ) is
   begin
      case Graphics_Implementation is
         when QEMU =>
            RamFB.Draw_2_Pixels_Raw (Position, Color1, Color2);
         when UBoot | None =>
            null;
      end case;
   end Draw_2_Pixels;

   procedure Draw_4_Pixels (
      X_Start : Integer;
      Y : Integer;
      Colors : Long_Long_Unsigned
   ) is
   begin
      case Graphics_Implementation is
         when UBoot =>
            UBoot_FB_Draw_4_Pixels (X_Start, Y, Colors);
         when QEMU =>
            null;
         when None =>
            null;
      end case;
   end Draw_4_Pixels;

   function Screen_Width return Integer is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_Width;
         when QEMU =>
            return Integer (RamFB.Width);
         when None =>
            return 0;
      end case;
   end Screen_Width;

   function Screen_Height return Integer is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_Height;
         when QEMU =>
            return Integer (RamFB.Height);
         when None =>
            return 0;
      end case;
   end Screen_Height;

   function Stride return Integer is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_Stride;
         when QEMU =>
            return Integer (RamFB.Stride);
         when None =>
            return 0;
      end case;
   end Stride;

   function Bytes_Per_Pixel return Integer is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_BPP;
         when QEMU =>
            return Integer (RamFB.Stride);
         when None =>
            return 0;
      end case;
   end Bytes_Per_Pixel;

   function Framebuffer_Start return Long_Long_Unsigned is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_Start;
         when QEMU =>
            return Long_Long_Unsigned (RamFB.FB_Start);
         when None =>
            return 0;
      end case;
   end Framebuffer_Start;

   procedure Enable_Graphics is
   begin
      case Graphics_Implementation is
         when QEMU =>
            if RamFB.Init_Default = False then
               IO.Put_String ("Failed to enable RAM framebuffer");
            end if;
         when others =>
            null;
      end case;
   end Enable_Graphics;

   function Graphics_Supports return Graphic_Features is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return (
               Draw_Pixel => True,
               Draw_2_Pixels => False,
               Draw_4_Pixels => True
            );
         when QEMU =>
            return (
               Draw_Pixel => True,
               Draw_2_Pixels => True,
               Draw_4_Pixels => False
            );
         when None =>
            return (
               Draw_Pixel => False,
               Draw_2_Pixels => False,
               Draw_4_Pixels => False
            );
      end case;
   end Graphics_Supports;

   function DRM_Pixel_Format return Pixel_Format is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return RG16;
         when QEMU =>
            return XR24;
         when None =>
            return None;
      end case;
   end DRM_Pixel_Format;

   procedure Flush_Address (Address : Long_Long_Unsigned) is
   begin
      case CC_Implementation is
         when StarFive =>
            StarFive_Flush_Address (Address);
         when None =>
            null;
      end case;
   end Flush_Address;
end Driver_Handler;