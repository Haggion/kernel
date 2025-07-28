with Lines;

package File_System.Block.Util is
   function File_Name_To_Line (Name : File_Name) return Lines.Line;
   function Line_To_File_Name (Line : Lines.Line) return File_Name;

   function Get_File_Name (Block_Address : Storage_Address)
      return File_Name;
   function Get_File_Name_Line (Block_Address : Storage_Address)
      return Lines.Line;
end File_System.Block.Util;