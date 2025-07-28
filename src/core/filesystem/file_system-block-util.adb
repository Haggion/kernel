package body File_System.Block.Util is
   function File_Name_To_Line (Name : File_Name) return Lines.Line is
      Line_Builder : Lines.Line := (others => Character'Val (0));
   begin
      for Index in Name'Range loop
         exit when Name (Index) = Character'Val (0);

         Line_Builder (Lines.Line_Index (Index + 1)) := Name (Index);
      end loop;

      return Line_Builder;
   end File_Name_To_Line;

   function Line_To_File_Name (Line : Lines.Line) return File_Name is
      File_Name_Builder : File_Name := (others => Character'Val (0));
   begin
      for Index in File_Name_Builder'Range loop
         exit when Line (Lines.Line_Index (Index + 1)) = Character'Val (0);

         File_Name_Builder (Index) := Line (Lines.Line_Index (Index + 1));
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
      return Lines.Line is
   begin
      return File_Name_To_Line (Get_File_Name (Block_Address));
   end Get_File_Name_Line;
end File_System.Block.Util;