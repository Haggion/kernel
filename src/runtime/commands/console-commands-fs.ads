--  with Lines; use Lines;
with File_System.Block.Util; use File_System.Block.Util;

package Console.Commands.FS is
   function List_Links (Args : Arguments) return Return_Data;
   function New_File (Args : Arguments) return Return_Data;
   function Jump_To (Args : Arguments) return Return_Data;
   function Link_Files (Args : Arguments) return Return_Data;

   function Append_To_File (Args : Arguments) return Return_Data;
   function Append_To_File (Text : Str_Ptr; Len : Natural) return Return_Data;
   function Append_Raw (Args : Arguments) return Return_Data;
   --  sets the text of a file
   function Write_To_File (Args : Arguments) return Return_Data;

   function Read (Args : Arguments) return Return_Data;

   function Info (Args : Arguments) return Return_Data;

   function Run (Args : Arguments) return Return_Data;
   function Run_Assembly (Code : File_Bytes_Pointer) return Return_Data;
   function Run_Shell (Code : File_Bytes_Pointer) return Return_Data;
end Console.Commands.FS;