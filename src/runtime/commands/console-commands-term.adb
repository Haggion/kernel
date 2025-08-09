with Renderer; use Renderer;
with Terminal;
with IO; use IO;

package body Console.Commands.Term is
   function Color (Args : Arguments) return Return_Data is
   begin
      if Args (0).Value /= Str then
         return Ret_Fail;
      elsif Args (1).Value /= Int then
         return Ret_Fail;
      end if;

      declare
         Option : constant Line := Args (0).Str_Val;
         Value : constant Color_Type := Color_Type (
            Args (1).Int_Val
         );
      begin
         if Option = Make_Line ("font") then
            Terminal.Font_Color := Value;
         elsif Option = Make_Line ("background") then
            Terminal.Background_Color := Value;
         else
            Put_String ("Invalid option");
            return Ret_Fail;
         end if;
      end;

      return Ret_Void;
   end Color;

   function Clear (Args : Arguments) return Return_Data is
      pragma Unreferenced (Args);
   begin
      Terminal.Clear;

      return Ret_Void;
   end Clear;
end Console.Commands.Term;