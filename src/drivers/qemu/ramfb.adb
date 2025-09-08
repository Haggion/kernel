with System; use System;
with System.Storage_Elements; use System.Storage_Elements;
with QEMU_FWCFG; use QEMU_FWCFG;
with Lines; use Lines;

package body RamFB is
   --  fw_cfg keys we'll use
   FW_CFG_FILE_DIR : constant := 16#0019#;

   --  DMA control bits
   --  DMA_CTL_ERROR  : constant := 2#1#;
   DMA_CTL_READ   : constant := 2#10#;
   --  DMA_CTL_SKIP   : constant := 2#100#;
   DMA_CTL_SELECT : constant := 2#1000#;
   DMA_CTL_WRITE  : constant := 2#10000#;

   --  Iterate FILE_DIR to find selector for "etc/ramfb"
   function Find_Ramfb_Selector return Unsigned_16 is
      Count_BE : aliased Unsigned_32;
   begin
      DMA_Operation (
         DMA_CTL_SELECT or
         Shift_Left (FW_CFG_FILE_DIR, 16) or
         DMA_CTL_READ,
         4,
         Count_BE'Address
      );

      declare
         Count : constant Unsigned_32 := BSwap32 (Count_BE);
         E     : aliased FWCFG_File;
      begin
         for I in 1 .. Integer (Count) loop
            DMA_Operation (
               DMA_CTL_READ,
               Unsigned_32 (E'Size / 8),
               E'Address
            );

            declare
               --  Convert BE selector for comparisons/printing
               Sel_Native : constant Unsigned_16 :=
                  BSwap16 (E.Sel);
               Nul        : Natural := E.Name'First;
            begin
               while Nul <= E.Name'Last and then E.Name (Nul) /= Null_Ch loop
                  Nul := Nul + 1;
               end loop;

               if E.Name (E.Name'First .. Nul - 1) = "etc/ramfb" then
                  return Sel_Native;
               end if;
            end;
         end loop;
      end;

      return 16#FFFF#;
   end Find_Ramfb_Selector;

   function Init_Custom (
      FB_PA  : System.Address;
      Width  : Unsigned_32;
      Height : Unsigned_32;
      Stride : Unsigned_32;
      Format : Unsigned_32
   ) return Boolean is
      Sel : Unsigned_16;
   begin
      Sel := Find_Ramfb_Selector;
      if Sel = 16#FFFF# then
         return False;
      end if;

      RamFB.Width  := Width;
      RamFB.Height := Height;
      RamFB.Stride := Stride;
      RamFB.Format := Format;
      RamFB.FB_Address := FB_PA;

      declare
         Cfg : aliased RAMFB_Cfg := (
            Addr   => BSwap64 (Unsigned_64 (To_Integer (FB_PA))),
            FourCC => BSwap32 (Format),
            Flags  => BSwap32 (0),
            Width  => BSwap32 (Width),
            Height => BSwap32 (Height),
            Stride => BSwap32 (Stride)
         );
      begin
         DMA_Operation (
            DMA_CTL_SELECT or
            Shift_Left (Unsigned_32 (Sel), 16) or
            DMA_CTL_WRITE,
            Unsigned_32 (Cfg'Size / 8),
            Cfg'Address
         );
      end;
      return True;
   end Init_Custom;

   function Init_Default return Boolean is
   begin
      --  we set format here because elaboration code
      --  (like defining a global variable as the result of
      --  a function) does not work yet with our runtime
      Format := FourCC ('X', 'R', '2', '4');

      return Init_Custom (
         FB_Address,
         Width,
         Height,
         Stride,
         Format
      );
   end Init_Default;

   function FB_Start return Unsigned_64 is
   begin
      return Unsigned_64 (To_Integer (FB_Address));
   end FB_Start;
end RamFB;
