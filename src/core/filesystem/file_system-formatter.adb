with File_System.Block; use File_System.Block;

package body File_System.Formatter is
   procedure Format (Blocks : Four_Bytes) is
      FS_Metadata : File_System_Metadata;
      F_Metadata : File_Metadata;

      Usage : constant Usage_Block := (True, True, True, others => False);
   begin
      --  same as number of blocks
      FS_Metadata.Bits_In_Usage_Blocks := Blocks;
      FS_Metadata.Num_Usage_Blocks := Byte (Blocks / (512 * 8) + 1);

      --  storage 0 will be boot block, skip for now
      Write_Block (1, Make_File_System_Metadata (FS_Metadata), False);
      Write_Block (2, Make_Usage_Block (Usage), False);

      F_Metadata.Name := ('r', 'o', 'o', 't', others => Character'Val (0));
      Write_Block (
         2 + Storage_Address (FS_Metadata.Num_Usage_Blocks),
         Make_File_Metadata (F_Metadata)
      );
   end Format;
end File_System.Formatter;