package body File_System.Block is
   --  Parsing functions
   function Parse_File_System_Metadata (Block : Block_Bytes)
      return File_System_Metadata is
      Parsed : File_System_Metadata;
   begin
      Parsed.Bits_In_Usage_Blocks := Bytes_To_Four_Bytes (
         Block (0),
         Block (1),
         Block (2),
         Block (3)
      );
      Parsed.Num_Usage_Blocks := Block (4);

      return Parsed;
   end Parse_File_System_Metadata;

   function Parse_File_Metadata (Block : Block_Bytes) return File_Metadata is
      Parsed : File_Metadata;
   begin
      --  parse file name
      for Index in 0 .. 31 loop
         Parsed.Name (Index) := Character'Val (Block (Index));
      end loop;

      --  files may have a description associated with them,
      --  which is stored in a separate block(s).
      --  description start is the address of the first description block,
      --  or zero if the file has no description
      Parsed.Description_Start := Bytes_To_Four_Bytes (
         Block (32),
         Block (33),
         Block (34),
         Block (35)
      );

      --  a file can have certain attributes associated with it:
      --  readonly, system, etc.
      Parsed.Attributes := Block (36);

      --  no time support yet, so I'll wait to implement this
      --  parse creation time (2 bytes)
      --  parse creation date (2 bytes)

      Parsed.Size := Bytes_To_Four_Bytes (
         Block (41),
         Block (42),
         Block (43),
         Block (44)
      );

      --  number of links the file has
      Parsed.Num_Links := Block (45);

      --  address pointing to the start of the file's data
      --  zero if the file has no data associated with it
      Parsed.Data_Start := Bytes_To_Four_Bytes (
         Block (46),
         Block (47),
         Block (48),
         Block (49)
      );

      --  the rest of the data in the block is just links
      if Parsed.Num_Links > 0 then
         for Index in 0 .. Natural (Parsed.Num_Links - 1) loop
            --  links have two parts, the address of the linked block
            --  and a byte defining the type of link (linked to, linked by)
            Parsed.Links (Index).Address := Bytes_To_Four_Bytes (
               Block (50 + 5 * Index),
               Block (51 + 5 * Index),
               Block (52 + 5 * Index),
               Block (53 + 5 * Index)
            );
            Parsed.Links (Index).Link_Type := Block (54 + 5 * Index);
         end loop;
      end if;

      return Parsed;
   end Parse_File_Metadata;

   function Parse_Usage_Block (Block : Block_Bytes) return Usage_Block is
      Parsed : Usage_Block;
   begin
      --  Every bit in a usage block corresponds to a boolean
      --  free/not free value for a block
      --  thus, since we recieve the block in bytes, we extract
      --  each bit and use them for the values
      for Index in 0 .. Block_Size - 1 loop
         Parsed (Index + 0) := Get_Bit (Block (Index), 7);
         Parsed (Index + 1) := Get_Bit (Block (Index), 6);
         Parsed (Index + 2) := Get_Bit (Block (Index), 5);
         Parsed (Index + 3) := Get_Bit (Block (Index), 4);
         Parsed (Index + 4) := Get_Bit (Block (Index), 3);
         Parsed (Index + 5) := Get_Bit (Block (Index), 2);
         Parsed (Index + 6) := Get_Bit (Block (Index), 1);
         Parsed (Index + 7) := Get_Bit (Block (Index), 0);
      end loop;

      return Parsed;
   end Parse_Usage_Block;

   --  Making functions
   function Make_File_System_Metadata (Metadata : File_System_Metadata)
      return Block_Bytes is
      Result : Block_Bytes := (others => 0);
      Bytes : constant Four_Byte_Array :=
         Four_Bytes_To_Bytes (Metadata.Bits_In_Usage_Blocks);
   begin
      Result (0) := Bytes (0);
      Result (1) := Bytes (1);
      Result (2) := Bytes (2);
      Result (3) := Bytes (3);

      Result (4) := Metadata.Num_Usage_Blocks;

      return Result;
   end Make_File_System_Metadata;

   function Make_File_Metadata (Metadata : File_Metadata)
      return Block_Bytes is
      Result : Block_Bytes := (others => 0);
      Bytes : Four_Byte_Array;
   begin
      for Index in 0 .. 31 loop
         Result (Index) := Character'Pos (Metadata.Name (Index));
      end loop;

      --  address of where description starts
      Bytes := Four_Bytes_To_Bytes (Metadata.Description_Start);
      Result (32) := Bytes (0);
      Result (33) := Bytes (1);
      Result (34) := Bytes (2);
      Result (35) := Bytes (3);

      Result (36) := Metadata.Attributes;

      --  put creation time
      --  put creation date

      --  append size to block bytes
      Bytes := Four_Bytes_To_Bytes (Metadata.Size);
      Result (41) := Bytes (0);
      Result (42) := Bytes (1);
      Result (43) := Bytes (2);
      Result (44) := Bytes (3);

      Result (45) := Metadata.Num_Links;

      --  address of where data starts
      Bytes := Four_Bytes_To_Bytes (Metadata.Data_Start);
      Result (46) := Bytes (0);
      Result (47) := Bytes (1);
      Result (48) := Bytes (2);
      Result (49) := Bytes (3);

      --  append links
      if Metadata.Num_Links > 0 then
         for Index in 0 .. Natural (Metadata.Num_Links) - 1 loop
            Bytes := Four_Bytes_To_Bytes (Metadata.Links (Index).Address);
            Result (50 + 5 * Index) := Bytes (0);
            Result (51 + 5 * Index) := Bytes (1);
            Result (52 + 5 * Index) := Bytes (2);
            Result (53 + 5 * Index) := Bytes (3);

            Result (54 + 5 * Index) := Metadata.Links (Index).Link_Type;
         end loop;
      end if;

      return Result;
   end Make_File_Metadata;

   function Make_Usage_Block (Block : Usage_Block)
      return Block_Bytes is
      Result : Block_Bytes := (others => 0);
      Temp : Byte;
   begin
      for Index in 0 .. Block_Size - 1 loop
         Temp := 0;

         Temp := Set_Bit (Temp, 7 + Index * 8, Block (0 + Index * 8));
         Temp := Set_Bit (Temp, 6 + Index * 8, Block (1 + Index * 8));
         Temp := Set_Bit (Temp, 5 + Index * 8, Block (2 + Index * 8));
         Temp := Set_Bit (Temp, 4 + Index * 8, Block (3 + Index * 8));
         Temp := Set_Bit (Temp, 3 + Index * 8, Block (4 + Index * 8));
         Temp := Set_Bit (Temp, 2 + Index * 8, Block (5 + Index * 8));
         Temp := Set_Bit (Temp, 1 + Index * 8, Block (6 + Index * 8));
         Temp := Set_Bit (Temp, 0 + Index * 8, Block (7 + Index * 8));

         Result (Index) := Temp;
      end loop;

      return Result;
   end Make_Usage_Block;
end File_System.Block;