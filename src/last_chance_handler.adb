with IO;
procedure Last_Chance_Handler
   (Source_Location : System.Address; Line : Integer) is
   pragma Unreferenced (Source_Location, Line);
begin
   IO.Put_Char ('X');

   loop
      null;
   end loop;
end Last_Chance_Handler;