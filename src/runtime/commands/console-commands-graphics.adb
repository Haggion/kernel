with Error_Handler; use Error_Handler;

package body Console.Commands.Graphics is
   Draw_Cmd_Name : constant Line :=
      Make_Line ("Console.Commands.Graphics#Draw");

   function Draw (Args : Arguments) return Return_Data is
      Check : Boolean := False;
   begin
      Check := Assert (
         Args (0).Value = Str,
         Make_Line (
            "Expected first argument to be a string of the type of figure"
         ),
         Draw_Cmd_Name
      ) and Assert (
         Args (1).Value = Int,
         Make_Line (
            "Expected second argument to be an integer X value of a point"
         ),
         Draw_Cmd_Name
      ) and Assert (
         Args (2).Value = Int,
         Make_Line (
            "Expected the third argument to be an integer Y value of a point"
         ),
         Draw_Cmd_Name
      );

      if not Check then
         return Ret_Fail;
      end if;

      if Args (0).Str_Val = "rect" then
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
      elsif Args (0).Str_Val = "point" then
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
         return Str_To_Color (Arg.Str_Val);
      elsif Arg.Value = Int then
         return Color_Type (Arg.Int_Val);
      else
         return 1;
      end if;
   end Arg_To_Color;
end Console.Commands.Graphics;