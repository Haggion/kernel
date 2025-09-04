with System;
with Interfaces; use Interfaces;

package RamFB is
   --  Properties of the framebuffer
   Height : Unsigned_32 := 720;
   Width : Unsigned_32 := 1280;
   Bytes_Per_Pixel : Unsigned_32 := 4;
   Stride : Unsigned_32 := Width * Bytes_Per_Pixel;
   FB_Address : System.Address := System'To_Address (16#81000000#);
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

   function FB_Start return Unsigned_64;
end RamFB;
