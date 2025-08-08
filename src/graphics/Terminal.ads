--  The terminal is the UI of the console

with Renderer;

package Terminal is
   Do_Refresh : Boolean := False;
   Font_Color : Renderer.Color_Type := 65535;
   Background_Color : Renderer.Color_Type := 1;

   procedure Put_Char (Ch : Character);
   procedure Clear;
   procedure Initialize;
end Terminal;