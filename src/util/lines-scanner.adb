package body Lines.Scanner is
   function Scan_To_Char (
      Input : Line;
      Start : Line_Index;
      Ch : Character
   ) return Scan_Result is
      Index : Line_Index := Start;
      LineBuilder : aliased Line;
      Result : Scan_Result;
   begin
      while Index'Valid loop
         --  stop looking if line finishes
         if Input (Index) = Null_Ch then
            Result.Content_Remains := False;
            exit;
         --  stop looking once we find Ch
         elsif Input (Index) = Ch then
            Result.Content_Remains := True;
            exit;
         end if;

         Append_To_Line (LineBuilder'Access, Input (Index));

         Index := Index + 1;
      end loop;

      Result.Result := LineBuilder;
      Result.Scanner_Position := Index + 1;

      return Result;
   end Scan_To_Char;
end Lines.Scanner;