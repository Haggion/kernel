--  The terminal is the UI of the console

with Renderer; use Renderer;

package Terminal is
   procedure Put_Char (
      Ch : Character;
      Self_Contained : Boolean := True
   );
   procedure Clear;
   procedure Initialize;

   procedure Set_Font_Color (New_Color : Color_Type);
   procedure Set_Background_Color (New_Color : Color_Type);

private
   --  ESC procedures
   procedure ESC_Color;
   procedure ESC_Cursor_Up;
   procedure ESC_Cursor_Down;
   procedure ESC_Cursor_Forward;
   procedure ESC_Cursor_Back;
   procedure ESC_Cursor_Next_Line;
   procedure ESC_Cursor_Prev_Line;
   procedure ESC_Cursor_Horizontal_Abs;
   procedure ESC_Cursor_Position;
   procedure ESC_Erase_In_Display;
   procedure ESC_Erase_In_Line;

   procedure Increment_Row;
   --  checks if the cursor is within bounds,
   --  and fixes it in the case it's not
   procedure Check_Cursor;

   --  for getting positions
   function Row_Start (N : Integer) return Integer;
   function Row_End   (N : Integer) return Integer;
   function Col_Start (N : Integer) return Integer;
   function Col_End   (N : Integer) return Integer;
end Terminal;