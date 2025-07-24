package IO is
   procedure Put_Char (Ch : Integer);
   pragma Import (C, Put_Char, "putchar");

   procedure Put_Char (Ch : Character);
   procedure Put_Line (Str : String);
   procedure Put_Int (Int : Integer);
   procedure New_Line;

   type Digit is range 0 .. 9;

private
   procedure Put_Int_Helper (Num : Integer);
   procedure Put_Digit (Num : Digit);
end IO;