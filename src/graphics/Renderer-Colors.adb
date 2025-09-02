--  here we initialize all colors for whatever
--  pixel format we happen to be using
with Driver_Handler; use Driver_Handler;
with IO; use IO;

package body Renderer.Colors is
   procedure Initialize_Colors is
      Selected_Colors : Pixel_Format_Colors;
   begin
      case DRM_Pixel_Format is
         when RG16 =>
            Selected_Colors := RG16_Colors;
         when XR24 =>
            Selected_Colors := XR24_Colors;
         when others =>
            --  just use as a backup
            Selected_Colors := RG16_Colors;
      end case;

      Red            := Selected_Colors.Red;
      Orange         := Selected_Colors.Orange;
      Yellow         := Selected_Colors.Yellow;
      Green          := Selected_Colors.Green;
      Blue           := Selected_Colors.Blue;
      Purple         := Selected_Colors.Purple;
      White          := Selected_Colors.White;
      Black          := Selected_Colors.Black;
      Magenta        := Selected_Colors.Magenta;
      Cyan           := Selected_Colors.Cyan;
      Gray           := Selected_Colors.Gray;
      Bright_Red     := Selected_Colors.Bright_Red;
      Bright_Green   := Selected_Colors.Bright_Green;
      Bright_Yellow  := Selected_Colors.Bright_Yellow;
      Bright_Blue    := Selected_Colors.Bright_Blue;
      Bright_Magenta := Selected_Colors.Bright_Magenta;
      Bright_Cyan    := Selected_Colors.Bright_Cyan;
      Bright_White   := Selected_Colors.Bright_White;

      Font_Color       := Selected_Colors.Font_Color;
      Background_Color := Selected_Colors.BG_Color;
   end Initialize_Colors;
end Renderer.Colors;