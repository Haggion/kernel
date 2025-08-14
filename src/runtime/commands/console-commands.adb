with Console.Commands.General; use Console.Commands.General;
with Console.Commands.Term; use Console.Commands.Term;
with Console.Commands.FS; use Console.Commands.FS;
with Console.Commands.Math; use Console.Commands.Math;
with Console.Commands.Graphics; use Console.Commands.Graphics;
with File_System.RAM_Disk;
with Driver_Handler; use Driver_Handler;
with IO; use IO;

package body Console.Commands is
   function Call_Builtin (
      Command : Line;
      Args : Arguments
   ) return Return_Data is
      procedure Print_Heap;
      pragma Import (C, Print_Heap, "print_heap");
   begin
      if Command = Make_Line ("keycode") then
         return Keycode (Args);
      elsif Command = Make_Line ("dh") then
         Print_Heap;
         return Ret_Void;
      elsif Command = Make_Line ("echo") then
         return Echo (Args);
      elsif Command = Make_Line ("dr") then
         File_System.RAM_Disk.Print_Disk;
         return Ret_Void;
      elsif Command = Make_Line ("shutdown") then
         Shutdown;
      elsif Command = Make_Line ("reboot") then
         Reboot;
      elsif Command = Make_Line ("time") then
         return Time (Args);
      elsif Command = Make_Line ("output") then
         return Redirect_Output (Args);
      elsif Command = Make_Line ("clear") then
         return Clear (Args);
      elsif Command = Make_Line ("color") then
         return Color (Args);
      elsif Command = Make_Line ("ll") then
         return List_Links (Args);
      elsif Command = Make_Line ("lnk") then
         return Link_Files (Args);
      elsif Command = Make_Line ("dlnk") then
         null;
      elsif Command = Make_Line ("edit") then
         null;
      elsif Command = Make_Line ("apnd") then
         return Append_To_File (Args);
      elsif Command = Make_Line ("apnd-raw") then
         return Append_Raw (Args);
      elsif Command = Make_Line ("write") then
         return Write_To_File (Args);
      elsif Command = Make_Line ("read") then
         return Read (Args);
      elsif Command = Make_Line ("new") then
         return New_File (Args);
      elsif Command = Make_Line ("jmp") then
         return Jump_To (Args);
      elsif Command = Make_Line ("del") then
         null;
      elsif Command = Make_Line ("info") then
         return Info (Args);
      elsif Command = Make_Line ("run") then
         return Run (Args);
      elsif Command = Make_Line ("+") then
         return Add (Args);
      elsif Command = Make_Line ("-") then
         return Subtract (Args);
      elsif Command = Make_Line ("*") then
         return Multiply (Args);
      elsif Command = Make_Line ("/") then
         return Divide (Args);
      elsif Command = Make_Line ("%") then
         return Modulus (Args);
      elsif Command = Make_Line ("draw") then
         return Draw (Args);
      elsif Command = Make_Line ("driver") then
         return Driver (Args);
      else
         Put_String ("Unknown command:", ' ');
         Put_Line (Command);
      end if;

      return Ret_Fail;
   end Call_Builtin;
end Console.Commands;