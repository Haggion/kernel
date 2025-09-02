with Driver_Handler; use Driver_Handler;
with IO; use IO;

package body Console.Commands.General is
   function Time (Args : Arguments) return Return_Data is
      function Tick_Time return Long_Integer;
      pragma Import (C, Tick_Time, "tick_time");
      function Cycle_Time return Long_Integer;
      pragma Import (C, Cycle_Time, "cycle_time");

      Data : Return_Data;
   begin
      Data.Value.Value := Int;

      if Args (0).Value /= Str then
         return Ret_Fail;
      end if;

      if Args (0).Str_Val = "tick" then
         Data.Value.Int_Val := Tick_Time;
      elsif Args (0).Str_Val = "cycle" then
         Data.Value.Int_Val := Cycle_Time;
      elsif Args (0).Str_Val = "hour" then
         Data.Value.Int_Val := Long_Integer (RTC_Hours);
      elsif Args (0).Str_Val = "minute" then
         Data.Value.Int_Val := Long_Integer (RTC_Minutes);
      elsif Args (0).Str_Val = "second" then
         Data.Value.Int_Val := Long_Integer (RTC_Seconds);
      else
         Put_String ("Invalid option");
         return Ret_Fail;
      end if;

      Data.Succeeded := True;
      return Data;
   end Time;

   function Keycode (Args : Arguments) return Return_Data is
      pragma Unreferenced (Args);
   begin
      return (
         (
            Int,
            Int_Val => Character'Pos (IO.Get_Char),
            Str_Val => Empty_Str
         ),
         True
      );
   end Keycode;

   function Redirect_Output (Args : Arguments) return Return_Data is
   begin
      if Args (0).Str_Val = "uart" then
         Main_Stream.Output := UART;
      elsif Args (0).Str_Val = "terminal" then
         Main_Stream.Output := Term;
      else
         Put_String ("Invalid option");
         return Ret_Fail;
      end if;

      return Ret_Void;
   end Redirect_Output;

   function Echo (Args : Arguments) return Return_Data is
   begin
      for I in Args'Range loop
         case Args (I).Value is
            when Void =>
               null;
            when Int =>
               Put_Int (Args (I).Int_Val);
            when Str =>
               Put_String (String (Args (I).Str_Val.all), Null_Ch);
         end case;
      end loop;

      return Ret_Void;
   end Echo;

   function Driver (Args : Arguments) return Return_Data is
   begin
      if Args (0).Str_Val = "get" then
         if Args (1).Str_Val = "uart" then
            case UART_Implementation is
               when None =>
                  Put_String ("None");
               when QEMU =>
                  Put_String ("QEMU");
               when StarFive =>
                  Put_String ("StarFive");
               when OpenSBI =>
                  Put_String ("OpenSBI");
            end case;
         elsif Args (1).Str_Val = "power" then
            case Power_Implementation is
               when None =>
                  Put_String ("None");
               when QEMU =>
                  Put_String ("QEMU");
               when OpenSBI =>
                  Put_String ("OpenSBI");
            end case;
         elsif Args (1).Str_Val = "rtc" then
            case RTC_Implementation is
               when None =>
                  Put_String ("None");
               when QEMU =>
                  Put_String ("QEMU");
               when StarFive =>
                  Put_String ("StarFive");
            end case;
         elsif Args (1).Str_Val = "graphics" then
            case Graphics_Implementation is
               when None =>
                  Put_String ("None");
               when UBoot =>
                  Put_String ("UBoot");
               when QEMU =>
                  Put_String ("QEMU");
            end case;
         elsif Args (1).Str_Val = "cc" then
            case CC_Implementation is
               when None =>
                  Put_String ("None");
               when StarFive =>
                  Put_String ("StarFive");
            end case;
         else
            Put_String ("Invalid driver type");
            return Ret_Fail;
         end if;
      elsif Args (0).Str_Val = "set" then
         if Args (1).Str_Val = "uart" then
            if Args (2).Str_Val = "none" then
               UART_Implementation := None;
            elsif Args (2).Str_Val = "qemu" then
               UART_Implementation := QEMU;
            elsif Args (2).Str_Val = "starfive" then
               UART_Implementation := StarFive;
            elsif Args (2).Str_Val = "opensbi" then
               UART_Implementation := OpenSBI;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = "power" then
            if Args (2).Str_Val = "none" then
               Power_Implementation := None;
            elsif Args (2).Str_Val = "qemu" then
               Power_Implementation := QEMU;
            elsif Args (2).Str_Val = "opensbi" then
               Power_Implementation := OpenSBI;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = "rtc" then
            if Args (2).Str_Val = "none" then
               RTC_Implementation := None;
            elsif Args (2).Str_Val = "qemu" then
               RTC_Implementation := QEMU;
            elsif Args (2).Str_Val = "starfive" then
               RTC_Implementation := StarFive;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = "graphics" then
            if Args (2).Str_Val = "none" then
               Graphics_Implementation := None;
            elsif Args (2).Str_Val = "uboot" then
               Graphics_Implementation := UBoot;
            elsif Args (2).Str_Val = "qemu" then
               Graphics_Implementation := QEMU;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = "cc" then
            if Args (2).Str_Val = "none" then
               CC_Implementation := None;
            elsif Args (2).Str_Val = "starfive" then
               CC_Implementation := StarFive;
            else
               Put_String ("Invalid driver");
            end if;
         else
            Put_String ("Invalid driver type");
            return Ret_Fail;
         end if;
      else
         Put_String ("Invalid option");
         return Ret_Fail;
      end if;

      return Ret_Void;
   end Driver;
end Console.Commands.General;