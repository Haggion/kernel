with Renderer.Text; use Renderer.Text;
with Driver_Handler;
with Lines.Converter;
with Renderer.Colors; use Renderer.Colors;

package body Terminal is
   Font_Color : Renderer.Color_Type := 57149;
   Background_Color : Renderer.Color_Type := 70;

   Row : Integer := 0;
   Col : Integer := 0;
   Font_Scale : constant Integer := 4;
   Font_Size : constant Integer := 5;
   Horizontal_Spacing : constant Integer := 1;
   Vertical_Spacing : constant Integer := 2;
   Terminal_Width : Integer;
   Col_Per_Row : Integer := 100;

   Curr_Font_Color : Color_Type := Font_Color;
   Curr_Background_Color : Color_Type := Background_Color;

   ESC_Code_N : Integer := 0;

   type State_Type is (Normal, ESC, ESC_SEQ);
   State : State_Type := Normal;

   procedure Initialize is
   begin
      Terminal_Width := Driver_Handler.Screen_Width;
      Col_Per_Row := Terminal_Width /
         ((Font_Size + Horizontal_Spacing) * Font_Scale) - 1;
   end Initialize;

   procedure Put_Char (Ch : Character) is
   begin
      if State = ESC_SEQ then
         case Ch is
            when '0' | '1' | '2' | '3' | '4'
               | '5' | '6' | '7' | '8' | '9' =>
               ESC_Code_N := ESC_Code_N
                  * 10
                  + Integer (
                     Lines.Converter.Char_To_Digit (Ch)
                  );
            when 'm' =>
               ESC_Color;
            when others =>
               State := Normal;
         end case;
         return;
      elsif State = ESC then
         if Ch = '[' then
            State := ESC_SEQ;
         else
            State := Normal;
         end if;
         return;
      end if;

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
      elsif Ch = Character'Val (27) then
         State := ESC;
      elsif Ch = Character'Val (127) then
         null;
      else
         Draw_Character (
            Ch,
            Col * (Font_Size + Horizontal_Spacing) * Font_Scale,
            Row * (Font_Size + Vertical_Spacing) * Font_Scale,
            Font_Scale,
            Curr_Font_Color,
            Curr_Background_Color
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
      Renderer.Draw_Rectangle (
         (0, 0),
         (
            Driver_Handler.Screen_Width,
            Driver_Handler.Screen_Height
         ),
         Curr_Background_Color
      );

      Row := 0;
      Col := 0;
   end Clear;

   procedure ESC_Color is
   begin
      case ESC_Code_N is
         when 0 =>
            Curr_Font_Color := Font_Color;
            Curr_Background_Color := Background_Color;
         when 30 =>
            Curr_Font_Color := Black;
         when 31 =>
            Curr_Font_Color := Red;
         when 32 =>
            Curr_Font_Color := Green;
         when 33 =>
            Curr_Font_Color := Yellow;
         when 34 =>
            Curr_Font_Color := Blue;
         when 35 =>
            Curr_Font_Color := Magenta;
         when 36 =>
            Curr_Font_Color := Cyan;
         when 37 =>
            Curr_Font_Color := White;
         when 39 =>
            Curr_Font_Color := Font_Color;
         when 40 =>
            Curr_Background_Color := Black;
         when 41 =>
            Curr_Background_Color := Red;
         when 42 =>
            Curr_Background_Color := Green;
         when 43 =>
            Curr_Background_Color := Yellow;
         when 44 =>
            Curr_Background_Color := Blue;
         when 45 =>
            Curr_Background_Color := Magenta;
         when 46 =>
            Curr_Background_Color := Cyan;
         when 47 =>
            Curr_Background_Color := White;
         when 49 =>
            Curr_Background_Color := Background_Color;
         when 90 =>
            Curr_Font_Color := Gray;
         when 91 =>
            Curr_Font_Color := Bright_Red;
         when 92 =>
            Curr_Font_Color := Bright_Green;
         when 93 =>
            Curr_Font_Color := Bright_Yellow;
         when 94 =>
            Curr_Font_Color := Bright_Blue;
         when 95 =>
            Curr_Font_Color := Bright_Magenta;
         when 96 =>
            Curr_Font_Color := Bright_Cyan;
         when 97 =>
            Curr_Font_Color := Bright_White;
         when 100 =>
            Curr_Background_Color := Gray;
         when 101 =>
            Curr_Background_Color := Bright_Red;
         when 102 =>
            Curr_Background_Color := Bright_Green;
         when 103 =>
            Curr_Background_Color := Bright_Yellow;
         when 104 =>
            Curr_Background_Color := Bright_Blue;
         when 105 =>
            Curr_Background_Color := Bright_Magenta;
         when 106 =>
            Curr_Background_Color := Bright_Cyan;
         when 107 =>
            Curr_Background_Color := Bright_White;
         when others =>
            null;
      end case;

      State := Normal;
      ESC_Code_N := 0;
   end ESC_Color;

   procedure Set_Font_Color (New_Color : Color_Type) is
   begin
      Font_Color := New_Color;
      Curr_Font_Color := Font_Color;
   end Set_Font_Color;

   procedure Set_Background_Color (New_Color : Color_Type) is
   begin
      Background_Color := New_Color;
      Curr_Background_Color := Background_Color;
   end Set_Background_Color;
end Terminal;