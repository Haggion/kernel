with Bitwise; use Bitwise;

package File_System is
   --  in bytes
   Block_Size : constant Natural := 512;
   Num_Blocks : constant Four_Bytes := 32;

   subtype Storage_Address is Four_Bytes;

   FSM_Address : constant Storage_Address := 1;
   UB_Address : constant Storage_Address := 2;

   type Block_Bytes is array (0 .. Block_Size - 1) of Byte
      with Component_Size => 8;
   type Device_Blocks is array (0 .. Num_Blocks - 1) of Block_Bytes;

   Storage : Device_Blocks;

   function Get_Block (Address : Storage_Address) return Block_Bytes;
   procedure Write_Block (
      Address : Storage_Address;
      Data : Block_Bytes;
      Mark_Block : Boolean := True
   );

   --  all this ram storage stuff going on in here needs to be moved
   --  ... eventually
   function Get_RAM_Block (Address : Storage_Address) return Block_Bytes;
   procedure Write_RAM_Block (Address : Storage_Address; Data : Block_Bytes);

   procedure Mark_Block_Used (Address : Storage_Address);
   function Get_Free_Address return Storage_Address;

   function Root return Block_Bytes;
   function Root_Address return Storage_Address;
end File_System;