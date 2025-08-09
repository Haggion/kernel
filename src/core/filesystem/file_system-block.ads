package File_System.Block is
   type File_System_Metadata is record
      Bits_In_Usage_Blocks : Four_Bytes;
      Num_Usage_Blocks : Byte;
   end record;

   type File_Name is array (0 .. 31) of Character;
   type Link_Container is record
      Address : Storage_Address := 0;
      Link_Type : Byte := 0;
   end record;
   --  93 is the maximum number of links
   --  that can fit in a 512 byte block (after
   --  using 46 bytes for the other data)
   type Link_Array is array (0 .. 93) of Link_Container;

   type File_Metadata is record
      Name : File_Name;
      Attributes : Byte := 0;
      Time_Was_Created : Byte := 0;
      Date_Was_Created : Byte := 0;
      Size : Storage_Address := 0;
      Num_Links : Byte := 0;
      Data_Start : Storage_Address := 0;
      Links : Link_Array;
   end record;

   type Usage_Block is array (0 .. Block_Size * 8 - 1) of Boolean;

   function Parse_File_System_Metadata (Block : Block_Bytes)
      return File_System_Metadata;
   function Parse_File_Metadata (Block : Block_Bytes)
      return File_Metadata;
   function Parse_Usage_Block (Block : Block_Bytes)
      return Usage_Block;

   function Make_File_System_Metadata (Metadata : File_System_Metadata)
      return Block_Bytes;
   function Make_File_Metadata (Metadata : File_Metadata)
      return Block_Bytes;
   function Make_Usage_Block (Block : Usage_Block)
      return Block_Bytes;
end File_System.Block;