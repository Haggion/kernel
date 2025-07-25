package Lines is
   type Line is array (Natural range 1 .. 256) of Character;

   function Are_Lines_Equal (Line1 : Line; Line2 : Line) return Boolean;
   function Make_Line (Text : String) return Line;

   procedure Append_To_Line (Target : access Line; Suffix : Character);
end Lines;