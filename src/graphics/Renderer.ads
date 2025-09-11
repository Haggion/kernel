with System.Unsigned_Types; use System.Unsigned_Types;
with Lines; use Lines;

package Renderer is
   type Point is record
      X : Integer;
      Y : Integer;
   end record;

   type Color_Type is range 0 .. 2 ** 32 - 1;

   --  There are procedures for drawing straight to the
   --  framebuffer, and for drawing to a window buffer which
   --  is later written to the framebuffer by the compositor.
   --  The procedures with an ID parameter are for the compositor.

   --  for drawing straight to framebuffer
   procedure Draw_Rectangle (
      P1 : Point;
      P2 : Point;
      Color : Color_Type
   );
   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type
   );
   pragma Inline (Draw_Pixel);

   --  for drawing to window buffer
   procedure Draw_Rectangle (
      P1 : Point;
      P2 : Point;
      Color : Color_Type;
      ID : Unsigned
   );
   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type;
      ID : Unsigned
   );
   pragma Inline (Draw_Pixel);

   procedure Flush_Area (
      P1 : Point;
      P2 : Point;
      Force : Boolean := False
   );

   procedure Initialize (Flush_Needed : Boolean);

   function Str_To_Color (Name : Str_Ptr) return Color_Type;

private
   type Rect is record
      X_Min : Integer;
      X_Max : Integer;
      Y_Min : Integer;
      Y_Max : Integer;
   end record;

   type Screen_Data_Record is record
      Screen_Height : Unsigned;
      Screen_Width : Unsigned;
      Bytes_Per_Pixel : Short_Unsigned;
      Stride : Unsigned;
      Framebuffer_Start : Long_Long_Unsigned;
      --  some graphics implementations (u-boot) work on cached memory
      Flush_Needed : Boolean;
   end record;

   Screen_Data : Screen_Data_Record;

   function Points_To_Rect (P1 : Point; P2 : Point) return Rect;

   --  Draws a rectangle using the Draw_4_Pixels procedure for efficiency
   procedure Draw_Rectangle_4Pix (
      P1 : Point;
      P2 : Point;
      Color : Color_Type
   );

   --  Draws a rectangle using only the Draw_Pixel procedure
   procedure Draw_Rectangle_1Pix (
      P1 : Point;
      P2 : Point;
      Color : Color_Type
   );
end Renderer;