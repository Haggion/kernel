with System;
with Interfaces; use Interfaces;

package RamFB is
   --  Properties of the framebuffer
   Height : Unsigned_32 := 720;
   Width : Unsigned_32 := 1280;
   Bytes_Per_Pixel : Unsigned_32 := 4;
   pragma Export (C, Bytes_Per_Pixel, "ramfb_bytes_per_pixel");
   Stride : Unsigned_32 := 1280 * 4;
   pragma Export (C, Stride, "ramfb_stride");
   FB_Address : System.Address := System'To_Address (16#82000F00#);
   pragma Export (C, FB_Address, "ramfb_fb_base");
   Format : Unsigned_32; --  definition delegated to init

   function Find_Ramfb_Selector return Unsigned_16;

   --  ramfb configuration blob
   type RAMFB_Cfg is record
      Addr   : Unsigned_64;   --  FB base
      FourCC : Unsigned_32;   --  pixel format
      Flags  : Unsigned_32 := 0;
      Width  : Unsigned_32;
      Height : Unsigned_32;
      Stride : Unsigned_32;
   end record;
   pragma Pack (RAMFB_Cfg);

   --  FB_PA is the address at which the
   --  framebuffer will be initialized
   function Init_Custom (
      FB_PA  : System.Address;
      Width  : Unsigned_32;
      Height : Unsigned_32;
      Stride : Unsigned_32;
      Format : Unsigned_32
   ) return Boolean;

   function Init_Default return Boolean;

   procedure Draw_Pixel (X : Integer; Y : Integer; Color : Integer);
   pragma Import (C, Draw_Pixel, "ramfb_draw_pixel");
   pragma Inline (Draw_Pixel);

   function FB_Start return Unsigned_64;
end RamFB;
