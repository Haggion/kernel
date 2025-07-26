with IO;

package body Error_Handler is
   procedure Throw (Error_Message : Lines.Line; File_Name : Lines.Line) is
   begin
      IO.Put_Char ('(');
      IO.Put_Line (File_Name, Character'Val (0));
      IO.Put_String (") ", Character'Val (0));
      IO.Put_Line (Error_Message);
   end Throw;
end Error_Handler;