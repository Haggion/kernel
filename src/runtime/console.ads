with Lines; use Lines;
with File_System.Block.Util; use File_System.Block.Util;

package Console is
   procedure Read_Eval_Print_Loop;
private
   procedure Execute_Command (To_Execute : Line);

   procedure List_Links (Arguments : Line);
   procedure New_File (Arguments : Line);
   procedure Jump_To (Arguments : Line);
   procedure Link_Files (Arguments : Line);

   procedure Append_To_File (Text : Line);
   procedure Append_To_File (Text : Line; Len : Natural);
   --  sets the text of a file
   procedure Write_To_File (Text : Line);

   procedure Read (Arguments : Line);

   procedure Info (Arguments : Line);

   procedure Run (Arguments : Line);
   procedure Run_Assembly (Code : File_Bytes_Pointer);
   procedure Run_Shell (Code : File_Bytes_Pointer);
   procedure Test;

   procedure Time (Arguments : Line);
end Console;