with Lines; use Lines;
with Ada.Unchecked_Deallocation;

package File_System.Block.Util is
   type Search_Result is record
      Found_Result : Boolean := False;
      File : File_Metadata;
      Address : Storage_Address := 0;
   end record;

   function File_Name_To_Line (Name : File_Name) return Line;
   function Line_To_File_Name (Text : Line) return File_Name;
   function Str_To_File_Name (Text : Str_Ptr) return File_Name;

   function Get_File_Name (Block_Address : Storage_Address)
      return File_Name;
   function Get_File_Name_Line (Block_Address : Storage_Address)
      return Line;

   function Get_File_From_Path (
      Current_Location : File_Metadata;
      Path : Str_Ptr
   ) return Search_Result;

   function Get_File_From_Path (
      Current_Location : File_Metadata;
      Path : Line
   ) return Search_Result;

   function Get_File_From_Link (
      Current_Location : File_Metadata;
      Path : Line
   ) return Search_Result;

   function Add_Link (
      To : File_Metadata;
      Link : Link_Container
   ) return File_Metadata;

   procedure Write_File (Address : Storage_Address; Data : File_Metadata);

   function Next_Data_Block (Data : Block_Bytes) return Four_Bytes;

   type File_Bytes is array (Natural range <>) of Byte;
   for File_Bytes'Alignment use 4;
   type File_Bytes_Pointer is access all File_Bytes;
   function Read_Into_Memory (
      Current_Location : File_Metadata
   ) return File_Bytes_Pointer;

   --  this procedure writes data into the current location file
   procedure Write_Data_After_Bytes (
      Data : File_Bytes_Pointer;
      Start : Natural;
      File : in out File_Metadata;
      File_Address : Storage_Address
   );

   procedure Free is new
      Ada.Unchecked_Deallocation (File_Bytes, File_Bytes_Pointer);
end File_System.Block.Util;