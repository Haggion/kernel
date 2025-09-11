with Error_Handler; use Error_Handler;

package body Renderer.Compositor is
   type Pixel_Array is array (Unsigned range <>) of Color_Type
      with Component_Size => 32;
   type Pixel_Array_Ptr is access Pixel_Array;
   Backbuffer : Pixel_Array_Ptr;

   type Window_Buffer is record
      Buffer : Pixel_Array_Ptr;
      Position : Point; -- top left corner starts here
      Size : Point;
      Transparency : Percentage;
      Initialized : Boolean := False;
   end record;

   type Buffer_Array is array (Unsigned range <>) of Window_Buffer;
   Buffers : Buffer_Array (0 .. 10);

   procedure Initialize_Compositor is
   begin
      Backbuffer := new Pixel_Array (0 ..
         Screen_Data.Screen_Width * Screen_Data.Screen_Height - 1
      );
   end Initialize_Compositor;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type;
      ID : Unsigned
   ) is
   begin
      Buffers (ID).Buffer (Y * Screen_Data.Screen_Width + X) := Color;
   end Draw_Pixel;

   procedure Render is
   begin
      for I in Buffers'Range loop
         if Buffers (I).Initialized then
            Render_Buffer (I);
         end if;
      end loop;
   end Render;

   procedure Render_Buffer (ID : Unsigned) is
   begin
      Render_Buffer_Section (
         (0, 0),
         (0, 0),
         ID
      );
   end Render_Buffer;

   procedure Render_Buffer_Section (
      Position : Point;
      Size     : Point;
      ID       : Unsigned
   ) is
      Buffer : constant Window_Buffer := Buffers (ID);
      Offset : constant Unsigned := Buffer.Position.X +
         Buffer.Position.Y * Screen_Data.Screen_Width;

      Real_Size : Point := Size;
   begin
      if not Buffer.Initialized then
         Throw ((
            Uninitialized_Error,
            Make_Line ("Buffer window was uninitialized"),
            Make_Line ("Renderer.Compositor#Renderer_Buffer"),
            0,
            No_Extra,
            OS
         ));
      end if;

      if Real_Size = (0, 0) then
         Real_Size := Buffer.Size;
      end if;

      declare
         J : Unsigned;
      begin
         for I in 0 .. Unsigned (Real_Size.X * Real_Size.Y - 1) loop
            J := ((I / Real_Size.X) + Position.Y) * Unsigned (Buffer.Size.X) +
               I mod Real_Size.X + Unsigned (Position.X);

            --  ensure pixel changed
            if Buffer.Buffer (J) /= Backbuffer (J + Offset) then
               Backbuffer (J + Offset) := Buffer.Buffer (J);
               Renderer.Draw_Pixel (
                  Integer (J mod Buffer.Size.X + Buffer.Position.X),
                  Integer (J / Buffer.Size.X + Buffer.Position.Y),
                  Buffer.Buffer (J)
               );
            end if;
         end loop;
      end;
   end Render_Buffer_Section;

   function Register_New_Buffer (
      Position : Point;
      Size : Point;
      Transparency : Percentage := 0
   ) return Unsigned is
      Buffer_ID : constant Unsigned := Find_Uninitialized_Buffer;
   begin
      Buffers (Buffer_ID).Initialized  := True;
      Buffers (Buffer_ID).Position     := Position;
      Buffers (Buffer_ID).Size         := Size;
      Buffers (Buffer_ID).Transparency := Transparency;
      Buffers (Buffer_ID).Buffer       := new Pixel_Array (
         0 .. Unsigned (Size.X * Size.Y - 1)
      );

      return Buffer_ID;
   end Register_New_Buffer;

   function Find_Uninitialized_Buffer return Unsigned is
   begin
      for I in Buffers'Range loop
         if not Buffers (I).Initialized then
            return I;
         end if;
      end loop;

      Throw ((
         Scarcity_Error,
         Make_Line ("Ran out of uninitialized buffers"),
         Make_Line ("Renderer.Compositor#Find_Uninitialized_Buffer"),
         0,
         No_Extra,
         OS
      ));
      return 0;
   end Find_Uninitialized_Buffer;

   --  operator definitions
   function "*" (LHS : Integer; RHS : Unsigned) return Unsigned is
   begin
      return Unsigned (LHS) * RHS;
   end "*";

   function "+" (LHS : Integer; RHS : Unsigned) return Unsigned is
   begin
      return Unsigned (LHS) + RHS;
   end "+";

   function "+" (LHS : Unsigned; RHS : Integer) return Unsigned is
   begin
      return LHS + Unsigned (RHS);
   end "+";

   function "mod" (LHS : Unsigned; RHS : Integer) return Unsigned is
   begin
      return LHS mod Unsigned (RHS);
   end "mod";

   function "/" (LHS : Unsigned; RHS : Integer) return Unsigned is
   begin
      return LHS / Unsigned (RHS);
   end "/";
end Renderer.Compositor;