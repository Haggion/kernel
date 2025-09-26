with Error_Handler; use Error_Handler;
with Driver_Handler;
with IO; use IO;

package body Renderer.Compositor is
   package DH renames Driver_Handler;

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

      --  initialize the backbuffer as black
      for I in Backbuffer'Range loop
         Backbuffer (I) := 0;
      end loop;
   end Initialize_Compositor;

   procedure Draw_Pixel (
      X : Integer;
      Y : Integer;
      Color : Color_Type;
      ID : Unsigned
   ) is
   begin
      Buffers (ID).Buffer (Y * Unsigned (Buffers (ID).Size.X) + X) := Color;
   end Draw_Pixel;

   procedure Render is
   begin
      for I in Buffers'Range loop
         if Buffers (I).Initialized then
            Render_Buffer (I);
         end if;
      end loop;
   end Render;

   procedure Render_Buffer_Sections (
      Abs_Position : Point;
      Size         : Point
   ) is
   begin
      for I in Buffers'Range loop
         if Buffers (I).Initialized then
            declare
               B_Size : constant Point := Buffers (I).Size;

               Pos : Point := (
                  Abs_Position.X - Buffers (I).Position.X,
                  Abs_Position.Y - Buffers (I).Position.Y
               );
               Siz : Point := Size;
            begin
               --  check that the buffer even exists at this position
               if
                  Pos.X + Siz.X < 0 or
                  Pos.Y + Siz.Y < 0 or
                  Pos.X > B_Size.X or
                  Pos.Y > B_Size.Y
               then
                  goto Loop_End;
               end if;

               --  make sure our position and size are within buffer's bounds
               if Pos.X < 0 then
                  Siz.X := Siz.X + Pos.X;
                  Pos.X := 0;
               elsif Siz.X > B_Size.X then
                  Siz.X := B_Size.X - Pos.X;
               end if;

               if Pos.Y < 0 then
                  Siz.Y := Siz.Y + Pos.Y;
                  Pos.Y := 0;
               elsif Siz.Y > B_Size.Y then
                  Siz.Y := B_Size.Y - Pos.Y;
               end if;

               Render_Buffer_Section (
                  Pos, Siz, I
               );
            end;
         end if;

         <<Loop_End>>
      end loop;
   end Render_Buffer_Sections;

   procedure Render_Buffer (ID : Unsigned) is
   begin
      Render_Buffer_Section (
         (0, 0),
         Buffers (ID).Size,
         ID
      );
   end Render_Buffer;

   procedure Render_Buffer_Section (
      Position : Point;
      Size     : Point;
      ID       : Unsigned
   ) is
      Buffer : constant Window_Buffer := Buffers (ID);

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
         Lim : constant Unsigned := Unsigned (Real_Size.X * Real_Size.Y);
         Features : constant DH.Graphic_Features := DH.Graphics_Supports;
         Draw_4px : constant Boolean := Features.Draw_4_Pixels;
         Draw_2px : constant Boolean := Features.Draw_2_Pixels;

         --  window frame buffer
         WFB : constant Pixel_Array_Ptr := Buffer.Buffer;

         I : Unsigned := 0;
         X : Unsigned := 0;
         Y : Unsigned := 0;
         Pos_X : constant Unsigned := Unsigned (Position.X);
         Pos_Y : constant Unsigned := Unsigned (Position.Y);

         Width : constant Unsigned := Unsigned (Real_Size.X);
         Buf_Width : constant Unsigned := Unsigned (Buffer.Size.X);

         Scr_Width : constant Unsigned := Screen_Data.Screen_Width;
         B_Pos_X   : constant Unsigned := Unsigned (
            Buffer.Position.X + Position.X
         );
         B_Pos_Y   : constant Unsigned := Unsigned (
            Buffer.Position.Y + Position.Y
         );

         --  horrifying, I know, but Ada needs to know the
         --  exact type of numerical constants I am using,
         --  so here we are.
         Four  : constant Unsigned := 4;
         Three : constant Unsigned := 3;
         Two   : constant Unsigned := 2;
         One   : constant Unsigned := 1;
         Zero  : constant Unsigned := 0;

         --  pragma Suppress (All_Checks);
      begin
         if Draw_4px then
            while I < Lim - 3 loop
               declare
                  Src : constant Unsigned :=
                     (Y + Pos_Y) * Buf_Width + (X + Pos_X);
                  Dst : constant Unsigned :=
                     (Y + B_Pos_Y) * Scr_Width + (X + B_Pos_X);

                  C0  : constant Color_Type := WFB (Src + Zero);
                  C1  : constant Color_Type := WFB (Src + One);
                  C2  : constant Color_Type := WFB (Src + Two);
                  C3  : constant Color_Type := WFB (Src + Three);
               begin
                  if C0 /= Backbuffer (Dst + Zero)
                  or C1 /= Backbuffer (Dst + One)
                  or C2 /= Backbuffer (Dst + Two)
                  or C3 /= Backbuffer (Dst + Three)
                  then
                     Backbuffer (Dst + Zero) := C0;
                     Backbuffer (Dst + One) := C1;
                     Backbuffer (Dst + Two) := C2;
                     Backbuffer (Dst + Three) := C3;

                     DH.Draw_4_Pixels.all (
                        Integer (X) + Buffer.Position.X + Position.X,
                        Integer (Y) + Buffer.Position.Y + Position.Y,
                        Long_Long_Unsigned (C0)
                        + Long_Long_Unsigned (C1) * 2 ** 16
                        + Long_Long_Unsigned (C2) * 2 ** 32
                        + Long_Long_Unsigned (C3) * 2 ** 48
                     );
                  end if;
               end;

               X := X + Four;

               if X >= Width then
                  X := X - Width;
                  Y := Y + One;
               end if;

               I := I + Four;
            end loop;
         end if;

         if Draw_2px then
            while I < Lim - 1 loop
               declare
                  Src : constant Unsigned :=
                     (Y + Pos_Y) * Buf_Width + (X + Pos_X);
                  Dst : constant Unsigned :=
                     (Y + B_Pos_Y) * Scr_Width + (X + B_Pos_X);

                  C0  : constant Color_Type := WFB (Src + Zero);
                  C1  : constant Color_Type := WFB (Src + One);
               begin
                  if C0 /= Backbuffer (Dst + Zero)
                     or C1 /= Backbuffer (Dst + One)
                  then
                     Backbuffer (Dst + Zero) := C0;
                     Backbuffer (Dst + One) := C1;

                     DH.Draw_2_Pixels_Raw.all (
                        Dst,
                        Integer (C0),
                        Integer (C1)
                     );
                  end if;

                  X := X + Two;

                  if X >= Width then
                     X := X - Width;
                     Y := Y + One;
                  end if;

                  I := I + Two;
               end;
            end loop;
         end if;

         while I < Lim loop
            declare
               Src : constant Unsigned :=
                  (Y + Pos_Y) * Buf_Width + (X + Pos_X);
               Dst : constant Unsigned :=
                  (Y + B_Pos_Y) * Scr_Width + (X + B_Pos_X);
               C   : constant Color_Type := WFB (Src);
            begin
               if C /= Backbuffer (Dst) then
                  Backbuffer (Dst) := C;
                  Renderer.Draw_Pixel (
                     Integer (X) + Buffer.Position.X + Position.X,
                     Integer (Y) + Buffer.Position.Y + Position.Y,
                     C
                  );
               end if;

               X := X + One;

               if X >= Width then
                  X := 0;
                  Y := Y + One;
               end if;

               I := I + One;
            end;
         end loop;
      end;

      Flush_Area (
         (
            Position.X + Buffer.Position.X,
            Position.Y + Buffer.Position.Y
         ),
         (
            Position.X + Buffer.Position.X + Real_Size.X,
            Position.Y + Buffer.Position.Y + Real_Size.Y
         )
      );
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

   procedure Move_Buffer (
      To : Point;
      ID : Unsigned
   ) is
      Buffer : constant Window_Buffer := Buffers (ID);
   begin
      if not Buffer.Initialized then
         Throw ((
            Uninitialized_Error,
            Make_Line ("Buffer window was uninitialized"),
            Make_Line ("Renderer.Compositor#Move_Buffer"),
            0,
            No_Extra,
            OS
         ));
      end if;

      Buffers (ID).Position := To;

      --  render buffer at new pos
      Render_Buffer (ID);
      --  rerender buffers at old pos
      Render_Buffer_Sections (Buffer.Position, Buffer.Size);
   end Move_Buffer;

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