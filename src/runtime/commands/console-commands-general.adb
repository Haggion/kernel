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

      if Args (0).Str_Val = Make_Line ("tick") then
         Data.Value.Int_Val := Tick_Time;
      elsif Args (0).Str_Val = Make_Line ("cycle") then
         Data.Value.Int_Val := Cycle_Time;
      elsif Args (0).Str_Val = Make_Line ("hour") then
         Data.Value.Int_Val := Long_Integer (RTC_Hours);
      elsif Args (0).Str_Val = Make_Line ("minute") then
         Data.Value.Int_Val := Long_Integer (RTC_Minutes);
      elsif Args (0).Str_Val = Make_Line ("second") then
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
            Str_Val => (others => Null_Ch)
         ),
         True
      );
   end Keycode;

   function Redirect_Output (Args : Arguments) return Return_Data is
   begin
      if Args (0).Str_Val = Make_Line ("uart") then
         Main_Stream.Output := UART;
      elsif Args (0).Str_Val = Make_Line ("terminal") then
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
               Put_Line (Args (I).Str_Val, Null_Ch);
         end case;
      end loop;

      return Ret_Void;
   end Echo;

   function Driver (Args : Arguments) return Return_Data is
   begin
      if Args (0).Str_Val = Make_Line ("get") then
         if Args (1).Str_Val = Make_Line ("uart") then
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
         elsif Args (1).Str_Val = Make_Line ("power") then
            case Power_Implementation is
               when None =>
                  Put_String ("None");
               when QEMU =>
                  Put_String ("QEMU");
               when OpenSBI =>
                  Put_String ("OpenSBI");
            end case;
         elsif Args (1).Str_Val = Make_Line ("rtc") then
            case RTC_Implementation is
               when None =>
                  Put_String ("None");
               when QEMU =>
                  Put_String ("QEMU");
               when StarFive =>
                  Put_String ("StarFive");
            end case;
         elsif Args (1).Str_Val = Make_Line ("graphics") then
            case Graphics_Implementation is
               when None =>
                  Put_String ("None");
               when UBoot =>
                  Put_String ("UBoot");
            end case;
         elsif Args (1).Str_Val = Make_Line ("cc") then
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
      elsif Args (0).Str_Val = Make_Line ("set") then
         if Args (1).Str_Val = Make_Line ("uart") then
            if Args (2).Str_Val = Make_Line ("none") then
               UART_Implementation := None;
            elsif Args (2).Str_Val = Make_Line ("qemu") then
               UART_Implementation := QEMU;
            elsif Args (2).Str_Val = Make_Line ("starfive") then
               UART_Implementation := StarFive;
            elsif Args (2).Str_Val = Make_Line ("opensbi") then
               UART_Implementation := OpenSBI;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = Make_Line ("power") then
            if Args (2).Str_Val = Make_Line ("none") then
               Power_Implementation := None;
            elsif Args (2).Str_Val = Make_Line ("qemu") then
               Power_Implementation := QEMU;
            elsif Args (2).Str_Val = Make_Line ("opensbi") then
               Power_Implementation := OpenSBI;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = Make_Line ("rtc") then
            if Args (2).Str_Val = Make_Line ("none") then
               RTC_Implementation := None;
            elsif Args (2).Str_Val = Make_Line ("qemu") then
               RTC_Implementation := QEMU;
            elsif Args (2).Str_Val = Make_Line ("starfive") then
               RTC_Implementation := StarFive;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = Make_Line ("graphics") then
            if Args (2).Str_Val = Make_Line ("none") then
               Graphics_Implementation := None;
            elsif Args (2).Str_Val = Make_Line ("uboot") then
               Graphics_Implementation := UBoot;
            else
               Put_String ("Invalid driver");
            end if;
         elsif Args (1).Str_Val = Make_Line ("cc") then
            if Args (2).Str_Val = Make_Line ("none") then
               CC_Implementation := None;
            elsif Args (2).Str_Val = Make_Line ("starfive") then
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