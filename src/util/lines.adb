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
      LineBuilder : Line := (others => Null_Ch);
   begin
      for Index in Text'Range loop
         if Index >= LineBuilder'Length then
            return LineBuilder;
         end if;

         LineBuilder (Index) := Text (Index);
      end loop;

      return LineBuilder;
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
end Lines;