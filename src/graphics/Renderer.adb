with Driver_Handler;

package body Renderer is
   procedure Draw_Line (
      From : Point;
      To : Point;
      Color : Color_Type
   ) is
      X0 : Integer := From.X;
      Y0 : Integer := From.Y;
      X1 : constant Integer := To.X;
      Y1 : constant Integer := To.Y;

      Dx : constant Integer := abs (X1 - X0);
      Dy : constant Integer := abs (Y1 - Y0);

      Sx : constant Integer := (if X0 < X1 then 1 else -1);
      Sy : constant Integer := (if Y0 < Y1 then 1 else -1);

      Err : Integer := Dx - Dy;
      E2  : Integer;
   begin
      loop
         Draw_Pixel (X0, Y0, Color);

         exit when X0 = X1 and Y0 = Y1;

         E2 := 2 * Err;

         if E2 > -Dy then
            Err := Err - Dy;
            X0 := X0 + Sx;
         end if;

         if E2 < Dx then
            Err := Err + Dx;
            Y0 := Y0 + Sy;
         end if;
      end loop;
   end Draw_Line;

   procedure Draw_Rectangle (
      Top_Left : Point;
      Bottom_Right : Point;
      Color : Color_Type
   ) is
   begin
      for X in Top_Left.X .. Bottom_Right.X loop
         for Y in Bottom_Right.Y .. Top_Left.Y loop
            Draw_Pixel (X, Y, Color);
         end loop;
      end loop;
   end Draw_Rectangle;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type
   ) is
   begin
      Driver_Handler.Draw_Pixel (
         X, Y, Integer (Color)
      );
   end Draw_Pixel;

   procedure Flush_Area (
      P1 : Point;
      P2 : Point
   ) is
      Bytes_Per_Pixel : constant Unsigned := Unsigned (
         Screen_Data.Bytes_Per_Pixel
      );
      Screen_Width : Unsigned renames Screen_Data.Screen_Width;

      Shape : constant Rect := Points_To_Rect (P1, P2);

      Width : constant Unsigned := Unsigned (
         (Shape.X_Max - Shape.X_Min)
      ) * Bytes_Per_Pixel / 64; --  div by 64 b/c 64 bytes per addr flushed
   begin
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
      Screen_Data.Flush_Needed := Flush_Needed;
      Screen_Data.Screen_Width := Unsigned (Driver_Handler.Screen_Width);
      Screen_Data.Screen_Height := Unsigned (Driver_Handler.Screen_Height);
      Screen_Data.Bytes_Per_Pixel := Short_Unsigned (
         Driver_Handler.Bytes_Per_Pixel
      );
      Screen_Data.Stride := Unsigned (Driver_Handler.Stride);
      Screen_Data.Framebuffer_Start := Driver_Handler.Framebuffer_Start;
   end Initialize;
end Renderer;