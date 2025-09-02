with System;
with Interfaces; use Interfaces;

package RamFB is
   --  combines four characters into a 32bit unsigned
   function FourCC (A, B, C, D : Character) return Unsigned_32;

   --  Properties of the framebuffer
   Height : Unsigned_32 := 720;
   Width : Unsigned_32 := 1280;
   Bytes_Per_Pixel : Unsigned_32 := 4;
   Stride : Unsigned_32 := Width * Bytes_Per_Pixel;
   FB_Address : System.Address := System'To_Address (16#81000000#);
   Format : Unsigned_32; --  definition delegated to init

   FWCFG_BASE : constant System.Address := System'To_Address (16#10100000#);

   --  fw_cfg MMIO layout
   type FWCFG_MMIO is record
      Data     : Unsigned_64;    --  +0x00
      Sel      : Unsigned_16;    --  +0x08
      pad0     : Unsigned_16;
      pad1     : Unsigned_32;
      DMA_Addr : System.Address; --  +0x10
   end record;
   pragma Volatile (FWCFG_MMIO);

   procedure FWCFG_Dump_Dir;

   for FWCFG_MMIO use record
      Data     at 16#00# range 0 .. 63;
      Sel      at 16#08# range 0 .. 15;
      DMA_Addr at 16#10# range 0 .. 63;
   end record;

   type FWCFG_DMA is record
      Control : Unsigned_32;
      Length  : Unsigned_32;
      Address : System.Address;
   end record;
   pragma Pack (FWCFG_DMA);

   procedure FWCFG_DMA_Operation (
      Control : Unsigned_32;
      Len : Unsigned_32;
      Phys : System.Address
   );

   function Find_Ramfb_Selector return Unsigned_16;

   --  fw_cfg file directory entry
   type FWCFG_File is record
      Size   : Unsigned_32;
      Sel : Unsigned_16;
      Rsvd   : Unsigned_16;
      Name   : String (1 .. 56);
   end record;
   pragma Pack (FWCFG_File); --  Important

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

   --  these swap the bytes in variously sized integers, needed
   --  as the fw_cfg requires numbers in big-endian,
   --  while all civilized machines work in little-endian
   function BSwap64 (X : Unsigned_64) return Unsigned_64;
   function BSwap32 (X : Unsigned_32) return Unsigned_32;
   function BSwap16 (X : Unsigned_16) return Unsigned_16;

   procedure Draw_Pixel (X : Integer; Y : Integer; Color : Integer);

   function FB_Start return Unsigned_64;
end RamFB;
