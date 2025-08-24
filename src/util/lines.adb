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

   function "=" (Left : Str_Ptr; Right : String) return Boolean is
   begin
      return Left.all = Right;
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

   procedure Append_To_Line (Appended : access Line; Appending : Line) is
      Len : Natural := Length (Appended.all);
   begin
      for Index in Appending'Range loop
         exit when Appending (Index) = Null_Ch;
         exit when Len + 1 > Natural (Appended'Last);

         Len := Len + 1;
         Appended (Line_Index (Len)) := Appending (Index);
      end loop;
   end Append_To_Line;

   procedure Append_New_Line (Target : access Line) is
      Len : constant Natural := Length (Target.all);
   begin
      Target (Line_Index (Len + 1)) := Character'Val (10);
      Target (Line_Index (Len + 2)) := Character'Val (13);
   end Append_New_Line;

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

   function Str_Substring (
      Text : Line;
      Start_Index : Natural;
      End_Index : Natural := 0
   ) return Str_Ptr is
      Len : constant Natural := Length (Text);
      String_Builder : Str_Ptr;
      SB_Index : Natural := 1;
      Real_End : Natural := End_Index;
   begin
      if Real_End = 0 then
         Real_End := Len;
      end if;

      String_Builder := new Str (1 .. Real_End + 1 - Start_Index);

      for Index in Start_Index .. Real_End loop
         exit when Text (Line_Index (Index)) = Null_Ch;

         String_Builder (SB_Index) :=
            Text (Line_Index (Index));
         SB_Index := SB_Index + 1;
      end loop;

      return String_Builder;
   end Str_Substring;

   function Length (Text : Line) return Natural is
   begin
      for Index in Line_Index loop
         if Text (Index) = Character'Val (0) then
            return Natural (Index) - 1;
         end if;
      end loop;

      return 256;
   end Length;
end Lines;