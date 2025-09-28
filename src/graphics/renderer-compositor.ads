package Renderer.Compositor is
   type Percentage is range 0 .. 100;

   procedure Initialize_Compositor;

   --  Draw a pixel on a specific buffer
   --  Doesn't update the framebuffer with
   --  the new pixel until the part of the
   --  buffer it lies on is updated.
   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type;
      ID : Unsigned
   );
   pragma Inline (Draw_Pixel);

   --  (re)render all initialized buffers
   procedure Render;
   --  (re)render the entirety of a specific buffer
   procedure Render_Buffer (ID : Unsigned);
   --  (re)render only a rectangular portion of a
   --  buffer, starting (top-left corner) at position
   --  and spanning with dimensions of size
   --  Position is relative to the buffer
   procedure Render_Buffer_Section (
      Position : Point;
      Size     : Point;
      ID       : Unsigned
   );

   --  Rerender any buffers which span the
   --  rectangle formed by abs_position and
   --  size, only in the part where they overlap
   procedure Render_Buffer_Sections (
      Abs_Position : Point;
      Size         : Point
   );

   --  creates a new buffer and returns the ID of new buffer
   function Register_New_Buffer (
      Position : Point;
      Size : Point;
      Transparency : Percentage := 0
   ) return Unsigned;

   --  changes the position of a buffer, and then
   --  updates the framebuffer
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