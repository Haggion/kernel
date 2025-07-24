package IO is
   procedure Put_Char (Ch : Integer);
   pragma Import (C, Put_Char, "putchar");

   procedure Put_Char (Ch : Character);

   procedure Put_Line (Str : String);
end IO;