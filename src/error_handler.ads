with Lines;

package Error_Handler is
   procedure Throw (Error_Message : Lines.Line; File_Name : Lines.Line);
   pragma Export (C, Throw, "_throw_error");
end Error_Handler;