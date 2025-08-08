with Error_Handler; use Error_Handler;
with IO; use IO;
with Ada.Unchecked_Conversion;
with System.Unsigned_Types; use System.Unsigned_Types;
with Lines.Converter; use Lines.Converter;

procedure Last_Chance_Handler
   (Source_Location : System.Address; Line : Integer) is
   function Adr_To_Int is new
      Ada.Unchecked_Conversion (System.Address, Long_Long_Unsigned);
begin
   String_Throw ("Some issue on line ", "last_chance_handler.adb");
   Put_Int (
      Long_Integer (Line)
   );

   Put_String (" At address 0x", Character'Val (0));
   Put_Line (
      Hex_To_Line (
         Adr_To_Int (Source_Location)
      )
   );

   loop
      null;
   end loop;
end Last_Chance_Handler;