package body Lines is
   function Are_Lines_Equal (Line1 : Line; Line2 : Line) return Boolean is
   begin
      for Index in Line1'Range loop
         if Line1 (Index) /= Line2 (Index) then
            return False;
         elsif Line1 (Index) = Character'Val (0) then
            return True;
         end if;
      end loop;

      return True;
   end Are_Lines_Equal;

   function Make_Line (Text : String) return Line is
      LineBuilder : Line := (others => Character'Val (0));
   begin
      for Index in Text'Range loop
         if Index >= LineBuilder'Length then
            return LineBuilder;
         end if;

         LineBuilder (Index) := Text (Index);
      end loop;

      return LineBuilder;
   end Make_Line;

   procedure Append_To_Line (Target : access Line; Suffix : Character) is
   begin
      for Index in Target'Range loop
         if Target (Index) = Character'Val (0) then
            Target (Index) := Suffix;
            return;
         end if;
      end loop;
   end Append_To_Line;
end Lines;