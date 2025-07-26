with Images;
with IO; use IO;

package body Console is
   procedure Read_Eval_Print_Loop is
      To_Execute : Lines.Line := (others => Character'Val (0));
   begin
      loop
         Put_String ("> ", Character'Val (0));
         To_Execute := Get_Line (True);
         New_Line;

         Put_Line (Execute_Command (To_Execute));
      end loop;
   end Read_Eval_Print_Loop;

   function Execute_Command (To_Execute : Lines.Line) return Lines.Line is
      procedure Print_Heap;
      pragma Import (C, Print_Heap, "print_heap");
   begin
      if Lines.Are_Lines_Equal (To_Execute, Lines.Make_Line ("keycode")) then
         return Images.Integer_Image (Character'Pos (IO.Get_Char));
      elsif Lines.Are_Lines_Equal (To_Execute, Lines.Make_Line ("")) then
         return Lines.Make_Line ("");
      elsif Lines.Are_Lines_Equal (To_Execute, Lines.Make_Line ("dmphp")) then
         Print_Heap;
         return Lines.Make_Line ("");
      end if;

      return Lines.Make_Line ("Unknown command");
   end Execute_Command;
end Console;