--  This driver handles anything todo with the
--  firmware configuration within QEMU

with System;
with Interfaces; use Interfaces;

package QEMU_FWCFG is
   FWCFG_BASE : constant System.Address := System'To_Address (16#10100000#);

   --  combines four characters into a 32bit unsigned
   function FourCC (A, B, C, D : Character) return Unsigned_32;

   --  fw_cfg MMIO layout
   type FWCFG_MMIO is record
      Data     : Unsigned_64;    --  +0x00
      Sel      : Unsigned_16;    --  +0x08
      pad0     : Unsigned_16;
      pad1     : Unsigned_32;
      DMA_Addr : System.Address; --  +0x10
   end record;
   pragma Volatile (FWCFG_MMIO);

   procedure DMA_Operation (
      Control : Unsigned_32;
      Len : Unsigned_32;
      Phys : System.Address
   );

   procedure Dump_Dir;

   type FWCFG_DMA is record
      Control : Unsigned_32;
      Length  : Unsigned_32;
      Address : System.Address;
   end record;
   pragma Pack (FWCFG_DMA);

   --  fw_cfg file directory entry
   type FWCFG_File is record
      Size   : Unsigned_32;
      Sel : Unsigned_16;
      Rsvd   : Unsigned_16;
      Name   : String (1 .. 56);
   end record;
   pragma Pack (FWCFG_File); --  Important

   --  these swap the bytes in variously sized integers, needed
   --  as the fw_cfg requires numbers in big-endian,
   --  while all civilized machines work in little-endian
   function BSwap64 (X : Unsigned_64) return Unsigned_64;
   function BSwap32 (X : Unsigned_32) return Unsigned_32;
   function BSwap16 (X : Unsigned_16) return Unsigned_16;
end QEMU_FWCFG;