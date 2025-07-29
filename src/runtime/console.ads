with Lines; use Lines;

package Console is
   procedure Read_Eval_Print_Loop;
private
   procedure Execute_Command (To_Execute : Line);

   procedure List_Links;
   procedure New_File (Arguments : Line);
   procedure Jump_To (Arguments : Line);
   procedure Link_Files (Arguments : Line);
   procedure Append_To_File (Text : Line);
   procedure Read;
end Console;