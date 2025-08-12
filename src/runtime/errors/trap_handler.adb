with Terminal;
with IO; use IO;
with Lines.Converter; use Lines.Converter;
with Driver_Handler;

package body Trap_Handler is
   procedure Handle_Trap (
      Cause : Long_Long_Unsigned;
      Exception_PC : Long_Unsigned;
      Trap_Value : Long_Long_Unsigned;
      Status : Long_Long_Unsigned
   ) is
   begin
      Terminal.Clear;
      Put_String ("Trap!!!");

      case Cause is
         when 0 =>
            Put_String ("Instruction address misaligned");
         when 1 =>
            Put_String ("Instruction address fault");
         when 2 =>
            Put_String ("Illegal instruction");
         when 3 =>
            Put_String ("Breakpoint");
         when 4 =>
            Put_String ("Load address misaligned");
         when 5 =>
            Put_String ("Load access fault");
         when 6 =>
            Put_String ("Store/AMO address misaligned");
         when 7 =>
            Put_String ("Store/AMO access fault");
         when 8 =>
            Put_String ("Environment call from U-mode");
         when 9 =>
            Put_String ("Environment call from S-mode");
         when 12 =>
            Put_String ("Instruction page fault");
         when 13 =>
            Put_String ("Load page fault");
         when 14 =>
            Put_String ("Reserved");
         when 15 =>
            Put_String ("Store/AMO page fault");
         when others =>
            Put_String ("Error", ' ');
            Put_Line (
               Hex_To_Line (Cause)
            );
      end case;

      Put_String ("PC: 0", 'x');
      Put_Line (
         Hex_To_Line (Long_Long_Unsigned (Exception_PC))
      );

      Put_String ("Trap value: 0", 'x');
      Put_Line (
         Hex_To_Line (Trap_Value)
      );

      Put_String ("Status register: 0", 'x');
      Put_Line (
         Hex_To_Line (Status)
      );

      Put_Char (ESC);
      Put_String (
         "[33mPress (c) to continue, (s) to shutdown, or (r) to reboot",
         ESC
      );
      Put_String ("[0m");

      declare
         Input : Character;
      begin
         loop
            Input := Get_Char;

            case Input is
               when 'c' =>
                  exit;
               when 's' =>
                  Driver_Handler.Shutdown;
               when 'r' =>
                  Driver_Handler.Reboot;
               when others =>
                  null;
            end case;
         end loop;
      end;
   end Handle_Trap;
end Trap_Handler;