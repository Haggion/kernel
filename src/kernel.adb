with IO; use IO;

procedure Kernel is
   Str : constant String := "Blegh";
begin
   Put_Int (52);
   Put_Line (Str);
   Put_Line ("Testing testing 123");
   Put_Int (-3277);
   New_Line;
   Put_Int (0);
   loop
      null;
   end loop;
end Kernel;