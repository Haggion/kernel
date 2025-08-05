with Renderer.Text; use Renderer.Text;
with Renderer;
with Driver_Handler;

package body Terminal is
   Row : Integer := 0;
   Col : Integer := 0;
   Font_Scale : constant Integer := 4;
   Font_Size : constant Integer := 5;
   Font_Spacing : constant Integer := 1;

   procedure Put_Char (Ch : Character) is
   begin
      if Ch = Character'Val (10) then
         Row := Row + 1;

         for I in 0 .. 10 loop
            Renderer.Draw_Rectangle (
               (1500, 1503),
               (2250, 0),
               Renderer.Color_Type (I * 3000 * 2 + 1)
            );
         end loop;
      elsif Ch = Character'Val (13) then
         Col := 0;
      elsif Ch = Character'Val (0) then
         null;
      elsif Ch = Character'Val (8) then
         if Col > 0 then
            Col := Col - 1;
         end if;
      else
         Draw_Character (
            Ch,
            Col * (Font_Size + Font_Spacing) * Font_Scale,
            Row * (Font_Size + Font_Spacing) * Font_Scale,
            Font_Scale,
            65535
         );
         Col := Col + 1;
      end if;
   end Put_Char;

   procedure Clear is
   begin
      for Y in 0 .. Driver_Handler.Screen_Height - 1 loop
         for X in 0 .. Driver_Handler.Screen_Width - 1 loop
            Renderer.Draw_Pixel (X, Y, 1);
         end loop;
      end loop;

      Row := 0;
      Col := 0;
   end Clear;
end Terminal;