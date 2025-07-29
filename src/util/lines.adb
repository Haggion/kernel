with Error_Handler;

package body Lines is
   function "=" (Left, Right : Line) return Boolean is
   begin
      for Index in Left'Range loop
         if Left (Index) /= Right (Index) then
            return False;
         --  lines are terminated by null characters,
         --  so if we reach one we can stop looking
         elsif Left (Index) = Null_Ch then
            --  we can assume true here since the case that only one
            --  string had the null char was eliminated by the first if
            return True;
         end if;
      end loop;

      return True;
   end "=";

   --  converts a string to a line
   --
   --  doesn't work implicitly since strings (usually)
   --  don't have the same length as a line type
   function Make_Line (Text : String) return Line is
      Line_Builder : Line := (others => Null_Ch);
   begin
      for Index in Text'Range loop
         if Index >= Line_Builder'Length then
            return Line_Builder;
         end if;

         Line_Builder (Line_Index (Index)) := Text (Index);
      end loop;

      return Line_Builder;
   end Make_Line;

   --  replaces the first null character in
   --  the line with the specified suffix
   procedure Append_To_Line (Target : access Line; Suffix : Character) is
   begin
      for Index in Target'Range loop
         if Target (Index) = Null_Ch then
            Target (Index) := Suffix;
            return;
         end if;
      end loop;

      --  this point is only reached if the line had no null characters
      Error_Handler.Throw (
         Make_Line ("Line is full"),
         Make_Line ("lines.adb")
      );
   end Append_To_Line;

   function Substring (
      Text : Line;
      Start_Index : Line_Index;
      End_Index : Line_Index := 256
   ) return Line is
      Line_Builder : Line := (others => Character'Val (0));
      LB_Index : Line_Index := 1;
   begin
      for Index in Start_Index .. End_Index loop
         exit when Text (Index) = Null_Ch;

         Line_Builder (LB_Index) := Text (Index);
         LB_Index := LB_Index + 1;
      end loop;

      return Line_Builder;
   end Substring;

   function Length (Text : Line) return Natural is
   begin
      for Index in Line_Index loop
         if Text (Index) = Character'Val (0) then
            return Natural (Index - 1);
         end if;
      end loop;

      return 256;
   end Length;
end Lines;