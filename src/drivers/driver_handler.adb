--  0 => None
--  1 => QEMU
--  2 => StarFive
--  3 => OpenSBI
--  4 => UBoot

with IO;

package body Driver_Handler is
   UART_Implementation : UART_Implementations;
   Power_Implementation : Power_Implementations;
   RTC_Implementation : RTC_Implementations;
   Graphics_Implementation : Graphics_Implementations;

   procedure Init is
      function UART_Default return Integer;
      pragma Import (C, UART_Default, "default_uart");
      function Power_Default return Integer;
      pragma Import (C, Power_Default, "default_power");
      function RTC_Default return Integer;
      pragma Import (C, RTC_Default, "default_rtc");
      function Graphics_Default return Integer;
      pragma Import (C, Graphics_Default, "default_graphics");

      UART_Selection : constant Integer := UART_Default;
      Power_Selection : constant Integer := Power_Default;
      RTC_Selection : constant Integer := RTC_Default;
      Graphics_Selection : constant Integer := Graphics_Default;
   begin
      case UART_Selection is
         when 1 =>
            UART_Implementation := QEMU;
         when 2 =>
            UART_Implementation := StarFive;
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
         when others =>
            RTC_Implementation := None;
      end case;

      case Graphics_Selection is
         when 4 =>
            Graphics_Implementation := UBoot;
         when others =>
            Graphics_Implementation := None;
      end case;

      if Graphics_Implementation /= None then
         IO.Main_Stream.Output := IO.Debug;
      end if;
   end Init;

   procedure UART_Put_Char (Ch : Integer) is
   begin
      case UART_Implementation is
         when QEMU =>
            QEMU_UART_Put_Char (Ch);
         when StarFive =>
            StarFive_UART_Put_Char (Ch);
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
         when None =>
            return -1;
      end case;
   end RTC_Seconds;

   function RTC_Minutes return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Minutes;
         when None =>
            return -1;
      end case;
   end RTC_Minutes;

   function RTC_Hours return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Hours;
         when None =>
            return -1;
      end case;
   end RTC_Hours;

   function RTC_Day return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Day;
         when None =>
            return -1;
      end case;
   end RTC_Day;

   function RTC_Month return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Month;
         when None =>
            return -1;
      end case;
   end RTC_Month;

   function RTC_Year return Integer is
   begin
      case RTC_Implementation is
         when StarFive =>
            return StarFive_RTC_Year;
         when None =>
            return -1;
      end case;
   end RTC_Year;

   procedure Enable_RTC is
   begin
      case RTC_Implementation is
         when StarFive =>
            StarFive_Enable_RTC;
         when None =>
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
         when None =>
            null;
      end case;
   end Draw_Pixel;

   function Screen_Width return Integer is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_Width;
         when None =>
            return 0;
      end case;
   end Screen_Width;

   function Screen_Height return Integer is
   begin
      case Graphics_Implementation is
         when UBoot =>
            return UBoot_FB_Height;
         when None =>
            return 0;
      end case;
   end Screen_Height;
end Driver_Handler;