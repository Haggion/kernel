with Error_Handler; use Error_Handler;
with IO; use IO;
with Ada.Unchecked_Conversion;

procedure Last_Chance_Handler
   (Source_Location : System.Address; Line : Integer) is
   function Adr_To_Int is new
      Ada.Unchecked_Conversion (System.Address, Long_Integer);
begin
   String_Throw ("Some issue on line ", "last_chance_handler.adb");
   Put_Int (Long_Integer (Line));
   Put_String (" At address ", Character'Val (0));
   Put_Int (Adr_To_Int (Source_Location));

   loop
      null;
   end loop;
end Last_Chance_Handler;