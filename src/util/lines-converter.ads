with System.Unsigned_Types; use System.Unsigned_Types;

package Lines.Converter is
   type Digit is range 0 .. 15;

   function Long_Int_To_Line (Int : Long_Integer) return Line;
   function Unsigned_To_Line (
      Num : Long_Long_Unsigned;
      Base : Short_Unsigned
   ) return Line;
   function Line_To_Long_Int (Text : Line) return Long_Integer;

   function Hex_To_Line (Num : Long_Long_Unsigned) return Line;
   function Binary_To_Line (Num : Long_Long_Unsigned) return Line;

   function Char_To_Digit (Num : Character) return Digit;

private
   function Digit_To_Char (Num : Digit) return Character;

   procedure Long_Int_To_Line_Helper (
      Num : Long_Integer;
      Line_Builder : access Line
   );

   procedure Unsigned_To_Line_Helper (
      Num : Long_Long_Unsigned;
      Base : Short_Unsigned;
      Line_Builder : access Line
   );
end Lines.Converter;