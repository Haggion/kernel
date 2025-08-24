with Renderer; use Renderer;
with Terminal;
with IO; use IO;
with Console.Commands.Graphics; use Console.Commands.Graphics;

package body Console.Commands.Term is
   function Color (Args : Arguments) return Return_Data is
   begin
      if Args (0).Value /= Str then
         return Ret_Fail;
      elsif Args (1).Value = Void then
         return Ret_Fail;
      end if;

      declare
         Option : constant Str_Ptr := Args (0).Str_Val;
         Value : constant Color_Type := Arg_To_Color (Args (1));
      begin
         if Option = "font" then
            Terminal.Set_Font_Color (Value);
         elsif Option = "background" then
            Terminal.Set_Background_Color (Value);
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