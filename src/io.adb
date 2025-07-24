with System.Unsigned_Types; use System.Unsigned_Types;

package body IO is
   procedure Put_Char (Ch : Character) is
   begin
      Put_Char (Character'Pos (Ch));
   end Put_Char;

   procedure Put_Line (Str : String) is
   begin
      for Index in Str'Range loop
         Put_Char (Str (Index));
      end loop;

      New_Line;
   end Put_Line;

   procedure Put_Int (Int : Integer) is
      Natural_Component : Unsigned := 100;
   begin
      if Int < 0 then
         Natural_Component := Unsigned (-Int);
         Put_Char ('-');
      elsif Int = 0 then
         Put_Char ('0');
         return;
      else
         Natural_Component := Unsigned (Int);
      end if;

      Put_Int_Helper (Integer (Natural_Component));
   end Put_Int;

   procedure New_Line is
   begin
      Put_Char (10);
   end New_Line;

   procedure Put_Int_Helper (Num : Integer) is
   begin
      if Num > 9 then
         Put_Int_Helper (Num / 10);
      end if;

      Put_Digit (Digit (Num mod 10));
   end Put_Int_Helper;

   procedure Put_Digit (Num : Digit) is
   begin
      case Num is
         when 0 =>
            Put_Char ('0');
         when 1 =>
            Put_Char ('1');
         when 2 =>
            Put_Char ('2');
         when 3 =>
            Put_Char ('3');
         when 4 =>
            Put_Char ('4');
         when 5 =>
            Put_Char ('5');
         when 6 =>
            Put_Char ('6');
         when 7 =>
            Put_Char ('7');
         when 8 =>
            Put_Char ('8');
         when 9 =>
            Put_Char ('9');
      end case;
   end Put_Digit;
end IO;