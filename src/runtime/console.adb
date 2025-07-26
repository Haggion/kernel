with IO; use IO;
with Lines.Scanner;

package body Console is
   procedure Read_Eval_Print_Loop is
      To_Execute : Lines.Line := (others => Character'Val (0));
   begin
      loop
         Put_String ("> ", Character'Val (0));
         To_Execute := Get_Line (True);
         New_Line;

         Execute_Command (To_Execute);
      end loop;
   end Read_Eval_Print_Loop;

   procedure Execute_Command (To_Execute : Line) is
      procedure Print_Heap;
      pragma Import (C, Print_Heap, "print_heap");
      Command : Lines.Scanner.Scan_Result;
   begin
      Command := Lines.Scanner.Scan_To_Char (To_Execute, 1, ' ');

      if Command.Result = Make_Line ("keycode") then
         Put_Int (Character'Pos (IO.Get_Char));
         New_Line;
      elsif Command.Result = Make_Line ("") then
         null;
      elsif Command.Result = Make_Line ("dumpheap") then
         Print_Heap;
      elsif Command.Result = Make_Line ("echo") then
         Put_Line (Substring (To_Execute, Command.Scanner_Position));
      else
         Put_String ("Unknown command:", ' ');
         Put_Line (Command.Result);
      end if;
   end Execute_Command;
end Console;