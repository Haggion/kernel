with IO;

package body Error_Handler is
   procedure Throw (Error_Message : Lines.Line; File_Name : Lines.Line) is
   begin
      IO.Put_Char ('(');
      IO.Put_Line (File_Name, Character'Val (0));
      IO.Put_String (") ", Character'Val (0));
      IO.Put_Line (Error_Message);
   end Throw;

   procedure String_Throw (Error_Message : String; File_Name : String) is
   begin
      IO.Put_Char ('(');
      IO.Put_String (File_Name, Character'Val (0));
      IO.Put_String (") ", Character'Val (0));
      IO.Put_String (Error_Message);
   end String_Throw;
end Error_Handler;