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
            Arg_To_Color (Args (5))
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
            Arg_To_Color (Args (5))
         );
      elsif Args (0).Str_Val = Make_Line ("point") then
         Draw_Pixel (
            Integer (Args (1).Int_Val),
            Integer (Args (2).Int_Val),
            Arg_To_Color (Args (3))
         );
      end if;

      return Ret_Void;
   end Draw;

   function Arg_To_Color (Arg : Atom) return Color_Type is
   begin
      if Arg.Value = Str then
         return Line_To_Color (Arg.Str_Val);
      elsif Arg.Value = Int then
         return Color_Type (Arg.Int_Val);
      else
         return 1;
      end if;
   end Arg_To_Color;
end Console.Commands.Graphics;