with IO; use IO;
with Ada.Unchecked_Conversion;
with Lines;

package body Error_Handler.Last_Chance is
   procedure Last_Chance_Handler
      (Source_Location : System.Address; Line : Integer) is
      type Line_Access is access Lines.Line;
      function Addr_To_Line is new
         Ada.Unchecked_Conversion (System.Address, Line_Access);
      Error : Builtin_Error;
   begin
      Error.Level := OS;
      Error.Kind := Unknown;
      Error.On_Line := Natural (Line);
      Error.From := Addr_To_Line (Source_Location).all;
      Error.Message := Make_Line ("Caught by last chance handler");
      Error.Optional_Params := On_Line;

      Throw (Error);
   end Last_Chance_Handler;
end Error_Handler.Last_Chance;