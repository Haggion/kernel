package Renderer.Compositor is
   type Percentage is range 0 .. 100;

   procedure Initialize_Compositor;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type;
      ID : Unsigned
   );
   pragma Inline (Draw_Pixel);

   --  (re)render all initialized buffers
   procedure Render;
   --  (re)render a specific buffer
   procedure Render_Buffer (ID : Unsigned);
   --  (re)render only a rectangular portion of a
   --  buffer, starting (top-left corner) at position
   --  and spanning with dimensions of size
   procedure Render_Buffer_Section (
      Position : Point;
      Size     : Point;
      ID       : Unsigned
   );

   procedure Render_Buffer_Sections (
      Abs_Position : Point;
      Size         : Point
   );

   --  returns ID of new buffer
   function Register_New_Buffer (
      Position : Point;
      Size : Point;
      Transparency : Percentage := 0
   ) return Unsigned;

   procedure Move_Buffer (
      To : Point;
      ID : Unsigned
   );
private
   function Find_Uninitialized_Buffer return Unsigned;

   function "*" (LHS : Integer; RHS : Unsigned) return Unsigned;
   function "+" (LHS : Integer; RHS : Unsigned) return Unsigned;
   function "+" (LHS : Unsigned; RHS : Integer) return Unsigned;
   function "mod" (LHS : Unsigned; RHS : Integer) return Unsigned;
   function "/" (LHS : Unsigned; RHS : Integer) return Unsigned;
end Renderer.Compositor;