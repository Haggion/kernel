with Renderer.Text; use Renderer.Text;
with Driver_Handler;
with Lines.Converter;
with Renderer.Colors; use Renderer.Colors;
with Lines; use Lines;
with Error_Handler; use Error_Handler;

package body Terminal is
   Line_Buffer_Size : constant := 100;
   type Line_Buffer_Index is range 0 .. Line_Buffer_Size - 1;
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
   ESC_Code_M : Integer := 0;

   type State_Type is (Normal, ESC, ESC_SEQ);
   State : State_Type := Normal;
   Last_State : State_Type := State;
   Collecting_N : Boolean := True;

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

   --  Self_Contained refers to if the procedure
   --  ought to do things other than rendering/parsing
   --  the given characters
   --  i.e., should it modify any history buffers
   procedure Put_Char (
      Ch : Character;
      Self_Contained : Boolean := True
   ) is
   begin
      --  if the state was switched to normal from an ESC sequence,
      --  reset N and M values
      if State = Normal and Last_State = ESC_SEQ then
         ESC_Code_N := 0;
         ESC_Code_M := 0;
      end if;

      Last_State := State;

      if State = ESC_SEQ then
         if Self_Contained then
            Output_History (OHI) (OI) := Ch;
            OI := OI + 1;
         end if;

         --  in most cases, the state is reverted to normal,
         --  so we do this by default and only in the cases it
         --  is not do we change it to ESC_SEQ (essentially
         --  leaving it in the same state)
         State := Normal;

         case Ch is
            when '0' | '1' | '2' | '3' | '4'
               | '5' | '6' | '7' | '8' | '9' =>
               if Collecting_N then
                  ESC_Code_N := ESC_Code_N
                     * 10
                     + Integer (
                        Lines.Converter.Char_To_Digit (Ch)
                     );
               else
                  ESC_Code_M := ESC_Code_M
                     * 10
                     + Integer (
                        Lines.Converter.Char_To_Digit (Ch)
                     );
               end if;

               State := ESC_SEQ;

            when ';' =>
               Collecting_N := False;
               State := ESC_SEQ;
            when 'm' =>
               ESC_Color;
            when 'A' =>
               ESC_Cursor_Up;
            when 'B' =>
               ESC_Cursor_Down;
            when 'C' =>
               ESC_Cursor_Forward;
            when 'D' =>
               ESC_Cursor_Back;
            when 'E' =>
               ESC_Cursor_Next_Line;
            when 'F' =>
               ESC_Cursor_Prev_Line;
            when 'G' =>
               ESC_Cursor_Horizontal_Abs;
            when 'H' =>
               ESC_Cursor_Position;
            when 'J' =>
               ESC_Erase_In_Display;
            when 'K' =>
               ESC_Erase_In_Line;
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
            Collecting_N := True;
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
      OHI := (OHI + 1) mod Line_Buffer_Size;
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
               mod Line_Buffer_Size
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

   procedure ESC_Cursor_Up is
   begin
      Row := Row - ESC_Code_N;

      Check_Cursor;
   end ESC_Cursor_Up;

   procedure ESC_Cursor_Down is
   begin
      Row := Row + ESC_Code_N;

      Check_Cursor;
   end ESC_Cursor_Down;

   procedure ESC_Cursor_Forward is
   begin
      Col := Col + ESC_Code_N;

      Check_Cursor;
   end ESC_Cursor_Forward;

   procedure ESC_Cursor_Back is
   begin
      Col := Col - ESC_Code_N;

      Check_Cursor;
   end ESC_Cursor_Back;

   procedure ESC_Cursor_Next_Line is
   begin
      Col := 0;

      ESC_Cursor_Down;
   end ESC_Cursor_Next_Line;

   procedure ESC_Cursor_Prev_Line is
   begin
      Col := 0;

      ESC_Cursor_Up;
   end ESC_Cursor_Prev_Line;

   procedure ESC_Cursor_Horizontal_Abs is
   begin
      Col := ESC_Code_N;

      Check_Cursor;
   end ESC_Cursor_Horizontal_Abs;

   procedure ESC_Cursor_Position is
   begin
      Row := ESC_Code_N - 1;
      Col := ESC_Code_M - 1;

      Check_Cursor;
   end ESC_Cursor_Position;

   procedure ESC_Erase_In_Display is
   begin
      case ESC_Code_N is
         when 0 =>
            --  clear everything from cursor to end of screen
            ESC_Erase_In_Line;

            if Row <= Row_Per_Col then
               Renderer.Draw_Rectangle (
                  (0, Terminal_Height - 1),
                  (
                     Terminal_Width - 1,
                     (Row + 1) *
                     (Font_Size + Vertical_Spacing) *
                     Font_Scale
                  ),
                  Background_Color
               );
            end if;
         when 1 =>
            --  clear everything from cursor to start of screen
            ESC_Erase_In_Line;

            if Row > 0 then
               Renderer.Draw_Rectangle (
                  (0, 0),
                  (
                     Terminal_Width - 1,
                     (Row - 1) *
                     (Font_Size + Vertical_Spacing) *
                     Font_Scale
                  ),
                  Background_Color
               );
            end if;
         when 2 =>
            --  clear entire screen, move cursor to start
            Clear;
         when others =>
            Throw ((
               Invalid_Argument,
               Make_Line ("Expected N code to be in range 0-2 for \e[nJ"),
               Make_Line ("Terminal#ESC_Erase_In_Display"),
               0,
               No_Extra,
               User
            ));
      end case;
   end ESC_Erase_In_Display;

   procedure ESC_Erase_In_Line is
   begin
      case ESC_Code_N is
         when 0 =>
            --  clear to end of line
            Renderer.Draw_Rectangle (
               (
                  Terminal_Width - 1,
                  Row * (Font_Size + Vertical_Spacing) * Font_Scale
               ),
               (
                  (Col *
                  (Font_Size + Horizontal_Spacing)) *
                  Font_Scale,
                  ((Row + 1) *
                  (Font_Size + Vertical_Spacing)) *
                  Font_Scale
               ),
               Renderer.Colors.Background_Color
            );
         when 1 =>
            --  clear to start of line
            Renderer.Draw_Rectangle (
               (
                  0,
                  Row * (Font_Size + Vertical_Spacing) * Font_Scale
               ),
               (
                  (Col *
                  (Font_Size + Horizontal_Spacing) +
                  Font_Size) *
                  Font_Scale,
                  ((Row + 1) *
                  (Font_Size + Vertical_Spacing)) *
                  Font_Scale
               ),
               Renderer.Colors.Background_Color
            );
         when 2 =>
            --  clear entire line
            Renderer.Draw_Rectangle (
               (0, Row * (Font_Size + Vertical_Spacing) * Font_Scale),
               (
                  Terminal_Width - 1,
                  ((Row + 1) *
                  (Font_Size + Vertical_Spacing)) *
                  Font_Scale
               ),
               Renderer.Colors.Background_Color
            );
         when others =>
            Throw ((
               Invalid_Argument,
               Make_Line ("Expected N code to be in range 0-2 for \e[nK"),
               Make_Line ("Terminal#ESC_Erase_In_Line"),
               0,
               No_Extra,
               User
            ));
      end case;
   end ESC_Erase_In_Line;

   procedure Check_Cursor is
   begin
      if Row > Row_Per_Col then
         Row := Row_Per_Col;
      elsif Row < 0 then
         Row := 0;
      end if;

      if Col > Col_Per_Row then
         Col := Col_Per_Row;
      elsif Col < 0 then
         Col := 0;
      end if;
   end Check_Cursor;
end Terminal;