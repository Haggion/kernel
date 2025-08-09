with Renderer.Text; use Renderer.Text;
with Driver_Handler;
with Renderer;

package body Terminal is
   Row : Integer := 0;
   Col : Integer := 0;
   Font_Scale : constant Integer := 4;
   Font_Size : constant Integer := 5;
   Font_Spacing : constant Integer := 1;
   Terminal_Width : Integer;
   Col_Per_Row : Integer := 100;

   procedure Initialize is
   begin
      Terminal_Width := Driver_Handler.Screen_Width;
      Col_Per_Row := Terminal_Width /
         ((Font_Size + Font_Spacing) * Font_Scale);
   end Initialize;

   procedure Put_Char (Ch : Character) is
   begin
      if Ch = Character'Val (10) then
         Row := Row + 1;
      elsif Ch = Character'Val (13) then
         Col := 0;
      elsif Ch = Character'Val (0) then
         null;
      elsif Ch = Character'Val (8) then
         if Col > 0 then
            Col := Col - 1;
         end if;
      elsif Ch = Character'Val (127) then
         null;
      else
         Draw_Character (
            Ch,
            Col * (Font_Size + Font_Spacing) * Font_Scale,
            Row * (Font_Size + Font_Spacing) * Font_Scale,
            Font_Scale,
            Font_Color,
            Background_Color
         );
         Col := Col + 1;

         if Col > Col_Per_Row then
            Col := 0;
            Row := Row + 1;
         end if;
      end if;
   end Put_Char;

   procedure Clear is
   begin
      for Y in 0 .. Driver_Handler.Screen_Height - 1 loop
         for X in 0 .. Driver_Handler.Screen_Width - 1 loop
            Renderer.Draw_Pixel (X, Y, Background_Color);
         end loop;
      end loop;

      Row := 0;
      Col := 0;

      Renderer.Flush_Area (
         (0, Driver_Handler.Screen_Height - 1),
         (Driver_Handler.Screen_Width - 1, 0)
      );
   end Clear;
end Terminal;