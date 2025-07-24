package body IO is
   procedure Put_Char (Ch : Character) is
   begin
      Put_Char (Character'Pos (Ch));
   end Put_Char;

   procedure Put_Line (Str : String) is
   begin
      for Index in 1 .. Str'Length loop
         Put_Char (Str (Index));
      end loop;

      Put_Char (10); -- newline
   end Put_Line;
end IO;