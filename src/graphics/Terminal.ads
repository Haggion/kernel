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
   procedure ESC_Color;
   procedure Increment_Row;
end Terminal;