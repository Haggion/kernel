--  Colors are all 16bit

package Renderer.Colors is
   procedure Initialize_Colors;

   Red              : Color_Type;
   Orange           : Color_Type;
   Yellow           : Color_Type;
   Green            : Color_Type;
   Blue             : Color_Type;
   Purple           : Color_Type;
   White            : Color_Type;
   Black            : Color_Type;
   Magenta          : Color_Type;
   Cyan             : Color_Type;
   Gray             : Color_Type;
   Bright_Red       : Color_Type;
   Bright_Green     : Color_Type;
   Bright_Yellow    : Color_Type;
   Bright_Blue      : Color_Type;
   Bright_Magenta   : Color_Type;
   Bright_Cyan      : Color_Type;
   Bright_White     : Color_Type;
   Font_Color       : Color_Type;
   Background_Color : Color_Type;
private
   type Pixel_Format_Colors is record
      Red            : Color_Type;
      Orange         : Color_Type;
      Yellow         : Color_Type;
      Green          : Color_Type;
      Blue           : Color_Type;
      Purple         : Color_Type;
      White          : Color_Type;
      Black          : Color_Type;
      Magenta        : Color_Type;
      Cyan           : Color_Type;
      Gray           : Color_Type;
      Bright_Red     : Color_Type;
      Bright_Green   : Color_Type;
      Bright_Yellow  : Color_Type;
      Bright_Blue    : Color_Type;
      Bright_Magenta : Color_Type;
      Bright_Cyan    : Color_Type;
      Bright_White   : Color_Type;
      Font_Color     : Color_Type;
      BG_Color       : Color_Type;
   end record;

   RG16_Colors : constant Pixel_Format_Colors := (
      Red            => 38912,
      Orange         => 64544,
      Yellow         => 65056,
      Green          => 3360,
      Blue           => 22,
      Purple         => 51231,
      White          => 48631,
      Black          => 1,
      Magenta        => 45078,
      Cyan           => 3382,
      Gray           => 25388,
      Bright_Red     => 57344,
      Bright_Green   => 7713,
      Bright_Yellow  => 59168,
      Bright_Blue    => 31,
      Bright_Magenta => 57372,
      Bright_Cyan    => 22527,
      Bright_White   => 65535,
      Font_Color     => 57149,
      BG_Color       => 70
   );

   XR24_Colors : constant Pixel_Format_Colors := (
      Red            => 16#009C0000#,
      Orange         => 16#00FF8600#,
      Yellow         => 16#00FFC700#,
      Green          => 16#0008A600#,
      Blue           => 16#000000B5#,
      Purple         => 16#00CE00FF#,
      White          => 16#00BDBEBD#,
      Black          => 16#00000008#,
      Magenta        => 16#00B500B5#,
      Cyan           => 16#0008A6B5#,
      Gray           => 16#00636563#,
      Bright_Red     => 16#00E70000#,
      Bright_Green   => 16#0018C708#,
      Bright_Yellow  => 16#00E7E700#,
      Bright_Blue    => 16#000000FF#,
      Bright_Magenta => 16#00E700E7#,
      Bright_Cyan    => 16#0052FFFF#,
      Bright_White   => 16#00FFFFFF#,
      Font_Color     => 16#00DEE7EF#,
      BG_Color       => 16#00000831#
   );
end Renderer.Colors;