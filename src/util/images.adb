with System.Unsigned_Types; use System.Unsigned_Types;

package body Images is
   function Integer_Image (Int : Long_Integer) return Lines.Line is
      LineBuilder : aliased Lines.Line := (others => Character'Val (0));
      Natural_Component : Unsigned;
   begin
      if Int < 0 then
         Natural_Component := Unsigned (-Int);
         LineBuilder (1) := '-';
      elsif Int = 0 then
         LineBuilder (1) := '0';
         return LineBuilder;
      else
         Natural_Component := Unsigned (Int);
      end if;

      Integer_Image_Helper
         (Long_Integer (Natural_Component), LineBuilder'Access);

      return LineBuilder;
   end Integer_Image;

   procedure Integer_Image_Helper
      (Num : Long_Integer; Line : access Lines.Line) is
      Ch : Character;
   begin
      if Num > 9 then
         Integer_Image_Helper (Num / 10, Line);
      end if;

      Ch := Digit_Image (Digit (Num mod 10));

      Lines.Append_To_Line (Line, Ch);
   end Integer_Image_Helper;

   function Digit_Image (Num : Digit) return Character is
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
      end case;
   end Digit_Image;
end Images;