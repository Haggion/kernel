with Lines; use Lines;

package Error_Handler is
   type Error_Type is (
      Syntax, Divide_By_Zero, Custom
   );
   type Error is record
      Kind : Error_Type;
      Message : Line;
      From : Line;
      On_Line : Natural;
   end record;

   procedure Throw (Error_Message : Lines.Line; File_Name : Lines.Line);
   procedure String_Throw (Error_Message : String; File_Name : String);
   pragma Export (C, Throw, "_throw_error");
end Error_Handler;