package Lines.Scanner is
   type Scan_Result is record
      Result : Line;
      Scanner_Position : Line_Index;
      Content_Remains : Boolean;
   end record;

   function Scan_To_Char (
      Input : Line;
      Start : Line_Index;
      Ch : Character
   ) return Scan_Result;
end Lines.Scanner;