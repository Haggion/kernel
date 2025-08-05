package Renderer is
   type Point is record
      X : Integer;
      Y : Integer;
   end record;

   type Color_Type is range 1 .. 2 ** 16;

   procedure Draw_Line (
      From : Point;
      To : Point;
      Color : Color_Type
   );

   procedure Draw_Rectangle (
      Top_Left : Point;
      Bottom_Right : Point;
      Color : Color_Type
   );

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type
   );
end Renderer;