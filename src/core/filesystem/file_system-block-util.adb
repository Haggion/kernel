with Lines.Scanner;
with IO; use IO;

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

end File_System.Block.Util;