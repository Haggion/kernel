with Error_Handler;

package body Lines.Converter is
   function Long_Int_To_Line (Int : Long_Integer) return Line is
      Line_Builder : aliased Line := (others => Character'Val (0));
      Natural_Component : Long_Integer;
   begin
      if Int < 0 then
         Natural_Component := -Int;
         Line_Builder (1) := '-';
      elsif Int = 0 then
         Line_Builder (1) := '0';
         return Line_Builder;
      else
         Natural_Component := Int;
      end if;

      Long_Int_To_Line_Helper (Natural_Component, Line_Builder'Access);

      return Line_Builder;
   end Long_Int_To_Line;

   procedure Long_Int_To_Line_Helper (
      Num : Long_Integer;
      Line_Builder : access Line
   ) is
      Ch : Character;
   begin
      if Num > 9 then
         Long_Int_To_Line_Helper (Num / 10, Line_Builder);
      end if;

      Ch := Digit_To_Char (Digit (Num mod 10));

      Append_To_Line (Line_Builder, Ch);
   end Long_Int_To_Line_Helper;

   function Unsigned_To_Line (
      Num : Long_Long_Unsigned;
      Base : Short_Unsigned
   ) return Line is
      Line_Builder : aliased Line := (others => Character'Val (0));
   begin
      Unsigned_To_Line_Helper (
         Num,
         Base,
         Line_Builder'Access
      );

      return Line_Builder;
   end Unsigned_To_Line;

   procedure Unsigned_To_Line_Helper (
      Num : Long_Long_Unsigned;
      Base : Short_Unsigned;
      Line_Builder : access Line
   ) is
      Ch : Character;
      --  make it easier for base-num operations
      B : constant Long_Long_Unsigned := Long_Long_Unsigned (Base);
   begin
      if Num >= B then
         Unsigned_To_Line_Helper (Num / B, Base, Line_Builder);
      end if;

      Ch := Digit_To_Char (Digit (Num mod B));

      Append_To_Line (Line_Builder, Ch);
   end Unsigned_To_Line_Helper;

   function Line_To_Long_Int (Text : Line) return Long_Integer is
      Result : Long_Integer := 0;
   begin
      for Index in Text'Range loop
         exit when Text (Index) = Null_Ch;

         Result := Result * 10;
         Result := Result + Long_Integer (Char_To_Digit (Text (Index)));
      end loop;

      return Result;
   end Line_To_Long_Int;

   function Digit_To_Char (Num : Digit) return Character is
   begin
      case Num is
         when 0 =>
            return '0';
         when 1 =>
            return '1';
         when 2 =>
            return '2';
         when 3 =>
            return '3';
         when 4 =>
            return '4';
         when 5 =>
            return '5';
         when 6 =>
            return '6';
         when 7 =>
            return '7';
         when 8 =>
            return '8';
         when 9 =>
            return '9';
         when 10 =>
            return 'A';
         when 11 =>
            return 'B';
         when 12 =>
            return 'C';
         when 13 =>
            return 'D';
         when 14 =>
            return 'E';
         when 15 =>
            return 'F';
      end case;
   end Digit_To_Char;

   function Char_To_Digit (Num : Character) return Digit is
   begin
      case Num is
         when '0' =>
            return 0;
         when '1' =>
            return 1;
         when '2' =>
            return 2;
         when '3' =>
            return 3;
         when '4' =>
            return 4;
         when '5' =>
            return 5;
         when '6' =>
            return 6;
         when '7' =>
            return 7;
         when '8' =>
            return 8;
         when '9' =>
            return 9;
         when 'A' =>
            return 10;
         when 'B' =>
            return 11;
         when 'C' =>
            return 12;
         when 'D' =>
            return 13;
         when 'E' =>
            return 14;
         when 'F' =>
            return 15;
         when others =>
            Error_Handler.String_Throw (
               "Character was not of digit",
               "lines-converter.adb"
            );
            return 0;
      end case;
   end Char_To_Digit;

   function Hex_To_Line (Num : Long_Long_Unsigned) return Lines.Line is
   begin
      return Unsigned_To_Line (Num, 16);
   end Hex_To_Line;

   function Binary_To_Line (Num : Long_Long_Unsigned) return Lines.Line is
   begin
      return Unsigned_To_Line (Num, 2);
   end Binary_To_Line;
end Lines.Converter;