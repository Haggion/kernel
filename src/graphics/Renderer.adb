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
end Renderer;