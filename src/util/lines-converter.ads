package Lines.Converter is
   function Long_Int_To_Line (Int : Long_Integer) return Lines.Line;

private
   type Digit is range 0 .. 9;
   function Digit_To_Char (Num : Digit) return Character;

   procedure Long_Int_To_Line_Helper (
      Num : Long_Integer;
      Line_Builder : access Line
   );
end Lines.Converter;