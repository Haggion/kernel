with Renderer; use Renderer;

package body Console.Commands.Graphics is
   function Draw (Args : Arguments) return Return_Data is
   begin
      if Args (0).Str_Val = Make_Line ("rect") then
         Draw_Rectangle (
            (
               Integer (Args (1).Int_Val),
               Integer (Args (2).Int_Val)
            ),
            (
               Integer (Args (3).Int_Val),
               Integer (Args (4).Int_Val)
            ),
            Color_Type (Args (5).Int_Val)
         );
      elsif Args (0).Str_Val = Make_Line ("line") then
         Draw_Line (
            (
               Integer (Args (1).Int_Val),
               Integer (Args (2).Int_Val)
            ),
            (
               Integer (Args (3).Int_Val),
               Integer (Args (4).Int_Val)
            ),
            Color_Type (Args (5).Int_Val)
         );
      elsif Args (0).Str_Val = Make_Line ("point") then
         Draw_Pixel (
            Integer (Args (1).Int_Val),
            Integer (Args (2).Int_Val),
            Color_Type (Args (3).Int_Val)
         );
      end if;

      return Ret_Void;
   end Draw;
end Console.Commands.Graphics;