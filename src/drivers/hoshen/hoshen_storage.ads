with System.Unsigned_Types; use System.Unsigned_Types;
with File_System; use File_System;
with Bitwise; use Bitwise;

package Hoshen_Storage is
   function Request_Block (Address : Unsigned) return Block_Bytes;
   procedure Send_Block (Address : Unsigned; Data : Block_Bytes);
   procedure Wait_Until_Active;

private
   --  turns an unsigned number as a list of bytes (LE)
   function Split_Into_Bytes (Number : Unsigned) return Byte_Array_Ptr;
end Hoshen_Storage;