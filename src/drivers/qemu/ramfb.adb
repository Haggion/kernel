with System; use System;
with Lines; use Lines;
with System.Storage_Elements; use System.Storage_Elements;
with IO; use IO;
with System.Unsigned_Types; use System.Unsigned_Types;
with System.Address_To_Access_Conversions;

package body RamFB is
   --  fw_cfg keys we'll use
   FW_CFG_FILE_DIR : constant := 16#0019#;

   --  DMA control bits
   --  DMA_CTL_ERROR  : constant := 2#1#;
   DMA_CTL_READ   : constant := 2#10#;
   --  DMA_CTL_SKIP   : constant := 2#100#;
   DMA_CTL_SELECT : constant := 2#1000#;
   DMA_CTL_WRITE  : constant := 2#10000#;

   function FourCC (A, B, C, D : Character) return Unsigned_32 is
   begin
      return Unsigned_32 (Character'Pos (A))
         or Shift_Left (Unsigned_32 (Character'Pos (B)), 8)
         or Shift_Left (Unsigned_32 (Character'Pos (C)), 16)
         or Shift_Left (Unsigned_32 (Character'Pos (D)), 24);
   end FourCC;

   --  MMIO register block
   Regs : aliased FWCFG_MMIO with Import, Address => FWCFG_BASE;

   procedure FWCFG_DMA_Operation (
      Control : Unsigned_32;
      Len : Unsigned_32;
      Phys : System.Address
   ) is
      DMA : aliased FWCFG_DMA := (
         Control => BSwap32 (Control),
         Length  => BSwap32 (Len),
         Address => System'To_Address (Integer_Address (
            BSwap64 (Unsigned_64 (To_Integer (Phys)))
         ))
      );
   begin
      Regs.DMA_Addr := System'To_Address (Integer_Address (
         BSwap64 (Unsigned_64 (To_Integer (DMA'Address)))
      ));
   end FWCFG_DMA_Operation;

   --  Byte swaping functions
   function BSwap16 (X : Unsigned_16) return Unsigned_16 is
   begin
      return Shift_Left (X and 16#00FF#, 8) or
         Shift_Right (X and 16#FF00#, 8);
   end BSwap16;

   function BSwap32 (X : Unsigned_32) return Unsigned_32 is
   begin
      return Shift_Left  (X and 16#000000FF#, 24) or
         Shift_Left  (X and 16#0000FF00#,  8) or
         Shift_Right (X and 16#00FF0000#,  8) or
         Shift_Right (X and 16#FF000000#, 24);
   end BSwap32;

   function BSwap64 (X : Unsigned_64) return Unsigned_64 is
   begin
      return Shift_Left  (X and 16#00000000000000FF#, 56) or
         Shift_Left  (X and 16#000000000000FF00#, 40) or
         Shift_Left  (X and 16#0000000000FF0000#, 24) or
         Shift_Left  (X and 16#00000000FF000000#,  8) or
         Shift_Right (X and 16#000000FF00000000#,  8) or
         Shift_Right (X and 16#0000FF0000000000#, 24) or
         Shift_Right (X and 16#00FF000000000000#, 40) or
         Shift_Right (X and 16#FF00000000000000#, 56);
   end BSwap64;

   --  Iterate FILE_DIR to find selector for "etc/ramfb"
   function Find_Ramfb_Selector return Unsigned_16 is
      Count_BE : aliased Unsigned_32;
   begin
      FWCFG_DMA_Operation (
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
            FWCFG_DMA_Operation (
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

   procedure FWCFG_Dump_Dir is
      Count_BE : aliased Unsigned_32;
   begin
      FWCFG_DMA_Operation (
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
            FWCFG_DMA_Operation (
               DMA_CTL_READ,
               Unsigned_32 (E'Size / 8),
               E'Address
            );

            declare
               Nul : Natural := E.Name'First;
            begin
               while Nul <= E.Name'Last and then E.Name (Nul) /= Null_Ch loop
                  Nul := Nul + 1;
               end loop;

               Put_String ("fw_cfg[");
               Put_Int (Long_Integer (I));
               Put_String ("]: sel=");
               Put_Hex (Long_Long_Unsigned (BSwap16 (E.Sel)));
               Put_String (" name=");
               Put_String (E.Name);
            end;
         end loop;
      end;
   end FWCFG_Dump_Dir;

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
         FWCFG_DMA_Operation (
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

   procedure Draw_Pixel (X : Integer; Y : Integer; Color : Integer) is
      package U32_A2A is new
         System.Address_To_Access_Conversions (Unsigned_32);

      Offset : constant Unsigned_64 :=
         Unsigned_64 (Y) * Unsigned_64 (Stride) +
         Unsigned_64 (X) * Unsigned_64 (Bytes_Per_Pixel);

      P : constant Address := FB_Address +
         Storage_Offset (Integer_Address (Offset));
   begin
      U32_A2A.To_Pointer (P).all := Unsigned_32 (Color);
   end Draw_Pixel;

   function FB_Start return Unsigned_64 is
   begin
      return Unsigned_64 (To_Integer (FB_Address));
   end FB_Start;
end RamFB;
