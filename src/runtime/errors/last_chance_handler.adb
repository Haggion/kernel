with Error_Handler; use Error_Handler;
with IO; use IO;
with Ada.Unchecked_Conversion;
with Driver_Handler;
with Lines;

procedure Last_Chance_Handler
   (Source_Location : System.Address; Line : Integer) is
   type Line_Access is access Lines.Line;
   function Addr_To_Line is new
      Ada.Unchecked_Conversion (System.Address, Line_Access);
begin
   New_Line;

   String_Throw ("Some issue on line ", "last_chance_handler.adb");

   Put_Char (ESC);
   Put_String ("[31m", Lines.Null_Ch);
   Put_Int (
      Long_Integer (Line)
   );

   Put_String (" in file", ' ');
   Put_Line (Addr_To_Line (Source_Location).all);

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
end Last_Chance_Handler;