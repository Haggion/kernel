with Lines.Scanner;
with IO; use IO;
with Error_Handler;

package body File_System.Block.Util is
   function File_Name_To_Line (Name : File_Name) return Line is
      Line_Builder : Line := (others => Character'Val (0));
   begin
      for Index in Name'Range loop
         exit when Name (Index) = Character'Val (0);

         Line_Builder (Line_Index (Index + 1)) := Name (Index);
      end loop;

      return Line_Builder;
   end File_Name_To_Line;

   function Line_To_File_Name (Text : Line) return File_Name is
      File_Name_Builder : File_Name := (others => Character'Val (0));
   begin
      for Index in File_Name_Builder'Range loop
         exit when Text (Line_Index (Index + 1)) = Character'Val (0);

         File_Name_Builder (Index) := Text (Line_Index (Index + 1));
      end loop;

      return File_Name_Builder;
   end Line_To_File_Name;

   function Str_To_File_Name (Text : Str_Ptr) return File_Name is
      File_Name_Builder : File_Name := (others => Character'Val (0));
   begin
      for Index in File_Name_Builder'Range loop
         exit when Index + 1 not in Text'Range;

         File_Name_Builder (Index) := Text (Index + 1);
      end loop;

      return File_Name_Builder;
   end Str_To_File_Name;

   --  this function assumes block_address points to a valid file metadata
   function Get_File_Name (Block_Address : Storage_Address)
      return File_Name is
   begin
      return Parse_File_Metadata (Get_Block (Block_Address)).Name;
   end Get_File_Name;

   function Get_File_Name_Line (Block_Address : Storage_Address)
      return Line is
   begin
      return File_Name_To_Line (Get_File_Name (Block_Address));
   end Get_File_Name_Line;

   function Get_File_From_Path (
      Current_Location : File_Metadata;
      Path : Str_Ptr
   ) return Search_Result is
   begin
      return Get_File_From_Path (
         Current_Location,
         Make_Line (Path.all)
      );
   end Get_File_From_Path;

   function Get_File_From_Path (
      Current_Location : File_Metadata;
      Path : Line
   ) return Search_Result is
      Result : Search_Result;
      Scan : Scanner.Scan_Result;
      Next_Result : Search_Result;
   begin
      --  path begins at root
      if Path (1) = '/' then
         Result.File := Parse_File_Metadata (Root);
         Scan.Scanner_Position := 2;

         --  means entire path is merely /
         if Path (2) = Character'Val (0) then
            Result.Address := Root_Address;
            Result.Found_Result := True;

            return Result;
         end if;
      else --  path is relative
         Result.File := Current_Location;
         Scan.Scanner_Position := 1;
      end if;

      Scan.Content_Remains := True;

      while Scan.Content_Remains loop
         Scan := Scanner.Scan_To_Char (
            Path,
            Scan.Scanner_Position,
            '/'
         );
         Next_Result := Get_File_From_Link (Result.File, Scan.Result);

         if not Next_Result.Found_Result then
            Result.Found_Result := False;
            return Result;
         end if;

         Result.File := Next_Result.File;
      end loop;

      Result.Address := Next_Result.Address;
      Result.Found_Result := True;

      return Result;
   end Get_File_From_Path;

   function Get_File_From_Link (
      Current_Location : File_Metadata;
      Path : Line
   ) return Search_Result is
      Result : Search_Result;
      Curr_FN : Line := (others => Character'Val (0));
   begin
      if Current_Location.Num_Links = 0 then
         Result.Found_Result := False;
         return Result;
      end if;

      for Index in 0 .. Natural (Current_Location.Num_Links) - 1 loop
         Curr_FN := Get_File_Name_Line (
            Current_Location.Links (Index).Address
         );

         if Path = Curr_FN then
            Result.Found_Result := True;
            Result.Address := Current_Location.Links (Index).Address;
            Result.File := Parse_File_Metadata (
               Get_Block (Result.Address)
            );

            return Result;
         end if;
      end loop;

      Result.Found_Result := False;
      return Result;
   end Get_File_From_Link;

   function Add_Link (
      To : File_Metadata;
      Link : Link_Container
   ) return File_Metadata is
      Result : File_Metadata := To;
   begin
      Result.Links (Natural (To.Num_Links)) := Link;
      Result.Num_Links := To.Num_Links + 1;

      return Result;
   end Add_Link;

   procedure Write_File (Address : Storage_Address; Data : File_Metadata) is
   begin
      File_System.Write_Block (
         Address,
         File_System.Block.Make_File_Metadata (Data)
      );
   end Write_File;

   function Next_Data_Block (Data : Block_Bytes) return Four_Bytes is
      Size : constant Natural := File_System.Block_Size;
   begin
      return Bytes_To_Four_Bytes (
         Data (Size - 4),
         Data (Size - 3),
         Data (Size - 2),
         Data (Size - 1)
      );
   end Next_Data_Block;

   function Read_Into_Memory (
      Current_Location : File_Metadata
   ) return File_Bytes_Pointer is
      Data : File_System.Block_Bytes;
      Next_Block : File_System.Storage_Address;
      Size : constant Natural := File_System.Block_Size;
      Bytes_Read : Four_Bytes := 0;
      Data_Pos : Natural := 0;

      Result : File_Bytes_Pointer;
   begin
      Result := new File_Bytes (0 .. Integer (Current_Location.Size) - 1);

      if Current_Location.Data_Start = 0 then
         Put_String ("This file has no data");
         return Result;
      end if;

      Data := File_System.Get_Block (Current_Location.Data_Start);
      Next_Block := Next_Data_Block (Data);

      while Bytes_Read < Current_Location.Size loop
         --  need to go to next block
         if Data_Pos >= Size - 4 then
            if Next_Block = 0 then
               Error_Handler.String_Throw
                  ("Expected another block", "console.adb");
               return Result;
            end if;

            Data := File_System.Get_Block (Next_Block);
            Next_Block := Next_Data_Block (Data);

            Data_Pos := 0;
         end if;

         Result (Natural (Bytes_Read)) := Data (Data_Pos);

         Data_Pos := Data_Pos + 1;
         Bytes_Read := Bytes_Read + 1;
      end loop;

      return Result;
   end Read_Into_Memory;

   procedure Write_Data_After_Bytes (
      Data : File_Bytes_Pointer;
      Start : Natural;
      File : in out File_Metadata;
      File_Address : Storage_Address
   ) is
      Block_Data_Size : constant Natural := Block_Size - 4;
      Initial_Size : constant Four_Bytes := Four_Bytes (Start);
      Size_Remaining : Four_Bytes := Initial_Size;

      Data_Buffer : Block_Bytes;
      Current_Block : Storage_Address;
   begin
      File.Size := Initial_Size + Four_Bytes (Data'Length);
      Current_Block := File.Data_Start;

      --  deal with edgecase that file has no data blocks yet
      if Current_Block = 0 then
         Current_Block := Get_Free_Address;
         Mark_Block_Used (Current_Block);

         File.Data_Start := Current_Block;
         Data_Buffer := (others => 0);
      else
         Data_Buffer := Get_Block (Current_Block);
      end if;

      Write_File (File_Address, File);

      --  go to the next block with free space
      while Size_Remaining >= Four_Bytes (Block_Data_Size) loop
         Size_Remaining := Size_Remaining - Four_Bytes (Block_Data_Size);

         declare
            Next_Block : constant Storage_Address :=
               Next_Data_Block (Data_Buffer);
         begin
            --  might need to make a new block to start writing in
            if Next_Block = 0 then
               --  put address of new block in old block
               declare
                  New_Block : constant Storage_Address :=
                     File_System.Get_Free_Address;
                  Bytes : constant Four_Byte_Array :=
                     Four_Bytes_To_Bytes (Current_Block);
               begin
                  File_System.Mark_Block_Used (Current_Block);

                  Data_Buffer (Block_Size - 4) := Bytes (0);
                  Data_Buffer (Block_Size - 3) := Bytes (1);
                  Data_Buffer (Block_Size - 2) := Bytes (2);
                  Data_Buffer (Block_Size - 1) := Bytes (3);

                  File_System.Write_Block (Current_Block, Data_Buffer);
                  Current_Block := New_Block;
                  Data_Buffer := (others => 0);
               end;
            else
               Data_Buffer := File_System.Get_Block (Current_Block);
               Current_Block := Next_Block;
            end if;
         end;
      end loop;

      --  start writing text
      declare
         Buffer_Pos : Natural := Natural (Size_Remaining);
      begin
         for Index in Data'Range loop
            if Buffer_Pos >= Block_Data_Size then
               declare
                  New_Block : File_System.Storage_Address;
               begin
                  --  make new block
                  New_Block := File_System.Get_Free_Address;
                  File_System.Mark_Block_Used (New_Block);

                  --  reference new block in prev block
                  declare
                     Bytes : constant Four_Byte_Array :=
                        Four_Bytes_To_Bytes (New_Block);
                  begin
                     Data_Buffer (Block_Size - 4) := Bytes (0);
                     Data_Buffer (Block_Size - 3) := Bytes (1);
                     Data_Buffer (Block_Size - 2) := Bytes (2);
                     Data_Buffer (Block_Size - 1) := Bytes (3);
                  end;
                  --  save prev block
                  File_System.Write_Block (Current_Block, Data_Buffer);

                  Data_Buffer := (others => 0);
                  Buffer_Pos := 0;

                  Current_Block := New_Block;
               end;
            end if;

            Data_Buffer (Buffer_Pos) := Data (Index);

            Buffer_Pos := Buffer_Pos + 1;
         end loop;

         --  save block
         File_System.Write_Block (Current_Block, Data_Buffer);
      end;
   end Write_Data_After_Bytes;
end File_System.Block.Util;