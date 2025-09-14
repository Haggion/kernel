with Driver_Handler;
with Renderer.Colors; use Renderer.Colors;
with Renderer.Compositor;

package body Renderer is
   procedure Draw_Rectangle (
      P1 : Point;
      P2 : Point;
      Color : Color_Type
   ) is
      Supports : constant Driver_Handler.Graphic_Features :=
         Driver_Handler.Graphics_Supports;
   begin
      if Supports.Draw_4_Pixels then
         Draw_Rectangle_4Pix (P1, P2, Color);
      elsif Supports.Draw_Pixel then
         Draw_Rectangle_1Pix (P1, P2, Color);
      end if;
   end Draw_Rectangle;

   procedure Draw_Rectangle_1Pix (
      P1 : Point;
      P2 : Point;
      Color : Color_Type
   ) is
      Shape : constant Rect := Points_To_Rect (P1, P2);
   begin
      for X in Shape.X_Min .. Shape.X_Max loop
         for Y in Shape.Y_Min .. Shape.Y_Max loop
            Draw_Pixel (
               X,
               Y,
               Color
            );
         end loop;
      end loop;

      Flush_Area (P1, P2);
   end Draw_Rectangle_1Pix;

   procedure Draw_Rectangle_4Pix (
      P1 : Point;
      P2 : Point;
      Color : Color_Type
   ) is
      Shape : constant Rect := Points_To_Rect (P1, P2);
      Width : constant Integer := (Shape.X_Max - Shape.X_Min) / 4;

      Repeated_Color : constant Long_Long_Unsigned :=
         Long_Long_Unsigned (Color) +
         Long_Long_Unsigned (Color) * 2 ** 16 +
         Long_Long_Unsigned (Color) * 2 ** 32 +
         Long_Long_Unsigned (Color) * 2 ** 48;
   begin
      for X in 0 .. Width loop
         for Y in Shape.Y_Min .. Shape.Y_Max loop
            Driver_Handler.Draw_4_Pixels.all (
               Shape.X_Min + X * 4,
               Y,
               Repeated_Color
            );
         end loop;
      end loop;

      for X in Shape.Y_Min + Width * 4 .. Shape.Y_Max loop
         for Y in Shape.Y_Min .. Shape.Y_Max loop
            Draw_Pixel (X, Y, Color);
         end loop;
      end loop;

      Flush_Area (P1, P2);
   end Draw_Rectangle_4Pix;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type
   ) is
   begin
      Driver_Handler.Draw_Pixel.all (
         X, Y, Integer (Color)
      );
   end Draw_Pixel;

   procedure Draw_Rectangle (
      P1 : Point;
      P2 : Point;
      Color : Color_Type;
      ID : Unsigned
   ) is
      Shape : constant Rect := Points_To_Rect (P1, P2);
   begin
      for X in Shape.X_Min .. Shape.X_Max loop
         for Y in Shape.Y_Min .. Shape.Y_Max loop
            Renderer.Compositor.Draw_Pixel (
               X,
               Y,
               Color,
               ID
            );
         end loop;
      end loop;
   end Draw_Rectangle;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type;
      ID : Unsigned
   ) is
   begin
      Renderer.Compositor.Draw_Pixel (X, Y, Color, ID);
   end Draw_Pixel;

   procedure Flush_Area (
      P1 : Point;
      P2 : Point;
      Force : Boolean := False
   ) is
      Bytes_Per_Pixel : constant Unsigned := Unsigned (
         Screen_Data.Bytes_Per_Pixel
      );
      Screen_Width : Unsigned renames Screen_Data.Screen_Width;

      Shape : constant Rect := Points_To_Rect (P1, P2);

      Width : constant Unsigned := Unsigned (
         (Shape.X_Max - Shape.X_Min)
      ) * Bytes_Per_Pixel / 64 + 1; --  div by 64 b/c 64 bytes per addr flushed
   begin
      if not (Force or Screen_Data.Flush_Needed) then
         return;
      end if;

      for X in 0 .. Width loop
         for Y in Shape.Y_Min .. Shape.Y_Max loop
            Driver_Handler.Flush_Address (
               Screen_Data.Framebuffer_Start +
               Long_Long_Unsigned (
                  Unsigned (Shape.X_Min) * Bytes_Per_Pixel + X * 64 +
                  Unsigned (Y)  * Screen_Width * Bytes_Per_Pixel
               )
            );
         end loop;
      end loop;
   end Flush_Area;

   function Points_To_Rect (P1 : Point; P2 : Point) return Rect is
      Data : Rect;
   begin
      if P1.X > P2.X then
         Data.X_Min := P2.X;
         Data.X_Max := P1.X;
      else
         Data.X_Min := P1.X;
         Data.X_Max := P2.X;
      end if;

      if P1.Y > P2.Y then
         Data.Y_Min := P2.Y;
         Data.Y_Max := P1.Y;
      else
         Data.Y_Min := P1.Y;
         Data.Y_Max := P2.Y;
      end if;

      return Data;
   end Points_To_Rect;

   procedure Initialize (Flush_Needed : Boolean) is
   begin
      Initialize_Colors;
      Driver_Handler.Enable_Graphics;

      Screen_Data.Flush_Needed := Flush_Needed;
      Screen_Data.Screen_Width := Unsigned (Driver_Handler.Screen_Width);
      Screen_Data.Screen_Height := Unsigned (Driver_Handler.Screen_Height);
      Screen_Data.Bytes_Per_Pixel := Short_Unsigned (
         Driver_Handler.Bytes_Per_Pixel
      );
      Screen_Data.Stride := Unsigned (Driver_Handler.Stride);
      Screen_Data.Framebuffer_Start := Driver_Handler.Framebuffer_Start;

      Renderer.Compositor.Initialize_Compositor;
   end Initialize;

   function Str_To_Color (Name : Str_Ptr) return Color_Type is
   begin
      if Name = "red" then
         return Red;
      elsif Name = "orange" then
         return Orange;
      elsif Name = "yellow" then
         return Yellow;
      elsif Name = "green" then
         return Green;
      elsif Name = "blue" then
         return Blue;
      elsif Name = "purple" then
         return Purple;
      elsif Name = "white" then
         return White;
      elsif Name = "black" then
         return Black;
      end if;

      return 1;
   end Str_To_Color;
end Renderer;