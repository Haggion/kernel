with Renderer.Text; use Renderer.Text;
with Driver_Handler;
with Lines.Converter;
with Renderer.Colors; use Renderer.Colors;
with Lines; use Lines;

package body Terminal is
   type Line_Buffer_Index is range 0 .. 99;
   type Line_Buffer is array (Line_Buffer_Index) of Line;

   --  Command_History : Line_Buffer := (others => Empty_Line);
   Output_History : Line_Buffer := (others => Empty_Line);
   --  buy using pointers that wrap around the buffers
   --  we can store the last x commands without ever
   --  having to shift the array itself
   --  CHI : Line_Buffer_Index := 0;
   OHI : Line_Buffer_Index := 0;
   --  CI : Line_Index := 1;
   OI : Line_Index := 1;

   Row : Integer := 0;
   Col : Integer := 0;
   Font_Scale : Integer := 4;
   Font_Size : constant Integer := 5;
   Horizontal_Spacing : constant Integer := 1;
   Vertical_Spacing : constant Integer := 2;
   Terminal_Width : Integer;
   Terminal_Height : Integer;
   Col_Per_Row : Integer := 100;
   Row_Per_Col : Integer := 100;

   Curr_Font_Color : Color_Type;
   Curr_Background_Color : Color_Type;

   ESC_Code_N : Integer := 0;

   type State_Type is (Normal, ESC, ESC_SEQ);
   State : State_Type := Normal;

   procedure Initialize is
   begin
      Terminal_Width := Driver_Handler.Screen_Width;
      Terminal_Height := Driver_Handler.Screen_Height;

      Font_Scale := Terminal_Width / 500;

      Col_Per_Row := Terminal_Width /
         ((Font_Size + Horizontal_Spacing) * Font_Scale) - 1;
      Row_Per_Col := Terminal_Height /
         ((Font_Size + Vertical_Spacing) * Font_Scale) - 1;

      Curr_Font_Color := Font_Color;
      Curr_Background_Color := Background_Color;
   end Initialize;

   procedure Put_Char (
      Ch : Character;
      Self_Contained : Boolean := True
   ) is
   begin
      if State = ESC_SEQ then
         if Self_Contained then
            Output_History (OHI) (OI) := Ch;
            OI := OI + 1;
         end if;

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
         if Self_Contained then
            Output_History (OHI) (OI) := Ch;
            OI := OI + 1;
         end if;

         if Ch = '[' then
            State := ESC_SEQ;
         else
            State := Normal;
         end if;
         return;
      end if;

      if Ch = Character'Val (10) then
         Increment_Row;
      elsif Ch = Character'Val (13) then
         Col := 0;
         OI := 1;
      elsif Ch = Character'Val (0) then
         null;
      elsif Ch = Character'Val (8) then
         if Col > 0 then
            Col := Col - 1;
         end if;

         if Self_Contained then
            OI := OI - 1;
            Output_History (OHI) (OI) := ' ';
         end if;
      elsif Ch = Character'Val (27) then
         State := ESC;

         if Self_Contained then
            Output_History (OHI) (OI) := Character'Val (27);
            OI := OI + 1;
         end if;
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

         if Self_Contained then
            Output_History (OHI) (OI) := Ch;
            OI := OI + 1;

            if Col > Col_Per_Row then
               Col := 0;
               Increment_Row;
            end if;
         end if;
      end if;
   end Put_Char;

   procedure Increment_Row is
      Initial_Col : constant Integer := Col;
      Initial_Row : constant Integer := Row;
      Curr_OHI : Line_Buffer_Index := 0;
   begin
      Row := Row + 1;
      OHI := (OHI + 1) mod 100;
      OI := 1;

      Output_History (OHI) := Empty_Line;

      if Row > Row_Per_Col then
         Clear;
         Row := 0;
         Col := 0;

         --  push up old text
         for I in 0 .. Row_Per_Col - 1 loop
            Curr_OHI := Line_Buffer_Index (
               (Integer (OHI) - Row_Per_Col + I)
               mod 100
            );

            loop
               exit when Output_History (Curr_OHI) (OI) = Null_Ch;
               Put_Char (
                  Output_History (
                     Curr_OHI
                  ) (OI),
                  False
               );

               OI := OI + 1;
            end loop;

            OI := 1;
            Col := 0;
            Row := Row + 1;
         end loop;

         Col := Initial_Col;
         Row := Initial_Row;
      end if;

      if Col /= 0 then
         for I in 1 .. Line_Index (Col) loop
            Output_History (OHI) (I) := ' ';
         end loop;
      end if;
      OI := Line_Index (Col + 1);
   end Increment_Row;

   procedure Clear is
   begin
      Renderer.Draw_Rectangle (
         (0, 0),
         (
            Driver_Handler.Screen_Width - 1,
            Driver_Handler.Screen_Height - 1
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