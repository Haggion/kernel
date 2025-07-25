with Lines;

package Images is
   function Integer_Image (Int : Integer) return Lines.Line;

private
   type Digit is range 0 .. 9;
   function Digit_Image (Num : Digit) return Character;

   procedure Integer_Image_Helper (Num : Integer; Line : access Lines.Line);
end Images;