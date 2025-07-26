package body Lines.Scanner is
   function Scan_To_Char (
      Input : Line;
      Start : Line_Index;
      Ch : Character
   ) return Scan_Result is
      Index : Line_Index := Start;
      Line_Builder : Line;
      LB_Index : Line_Index := 1;
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

         Line_Builder (LB_Index) := Input (Index);

         Index := Index + 1;
         LB_Index := LB_Index + 1;
      end loop;

      Result.Result := Line_Builder;
      Result.Scanner_Position := Index + 1;

      return Result;
   end Scan_To_Char;
end Lines.Scanner;