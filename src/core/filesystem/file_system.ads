with Bitwise; use Bitwise;

package File_System is
   --  in bytes
   Block_Size : constant Natural := 512;
   Num_Blocks : constant Four_Bytes := 16;

   subtype Storage_Address is Four_Bytes;

   FSM_Address : constant Storage_Address := 1;
   UB_Address : constant Storage_Address := 2;

   type Block_Bytes is array (0 .. Block_Size - 1) of Byte;
   type Device_Blocks is array (0 .. Num_Blocks - 1) of Block_Bytes;

   function Get_Block (Address : Storage_Address) return Block_Bytes;
   procedure Write_Block (Address : Storage_Address; Data : Block_Bytes);

   procedure Mark_Block_Used (Address : Storage_Address);
   function Get_Free_Address return Storage_Address;

   function Root return Block_Bytes;
   function Root_Address return Storage_Address;
end File_System;