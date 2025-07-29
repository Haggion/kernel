with File_System.RAM_Disk; use File_System.RAM_Disk;
with File_System.Block; use File_System.Block;
with Error_Handler;

package body File_System is
   function Get_Block (Address : Storage_Address) return Block_Bytes is
   begin
      return Storage (Address);
   end Get_Block;

   procedure Write_Block (Address : Storage_Address; Data : Block_Bytes) is
   begin
      Storage (Address) := Data;

      Mark_Block_Used (Address);
   end Write_Block;

   procedure Mark_Block_Used (Address : Storage_Address) is
      Usage_Byte : Byte;
      Usage : Block_Bytes renames Storage (UB_Address);
   begin
      Usage_Byte := Usage (Natural (Address / 8));
      Usage_Byte := Set_Bit (Usage_Byte, Natural (7 - Address mod 8), True);

      Usage (Natural (Address / 8)) := Usage_Byte;
   end Mark_Block_Used;

   function Get_Free_Address return Storage_Address is
      Usage : Block_Bytes renames Storage (UB_Address);
   begin
      for Index in Usage'Range loop
         --  if a byte holds a number other than 255,
         --  then at least one of it's bits isn't flipped,
         --  meaning it's indicating at least one free block
         if Usage (Index) /= 255 then
            for Bit in reverse 0 .. 7 loop
               if not Get_Bit (Usage (Index), Bit) then
                  return Storage_Address (Index * 8 + 7 - Bit);
               end if;
            end loop;
         end if;
      end loop;

      Error_Handler.String_Throw ("Ran out of storage", "file_system.adb");
      return 0;
   end Get_Free_Address;

   function Root return Block_Bytes is
   begin
      return Storage (Root_Address);
   end Root;

   function Root_Address return Storage_Address is
      FS_Metadata : constant File_System_Metadata :=
         Parse_File_System_Metadata (Storage (1));
   begin
      return Four_Bytes (2 + FS_Metadata.Num_Usage_Blocks);
   end Root_Address;
end File_System;