with Console.Commands.General; use Console.Commands.General;
with Console.Commands.Term; use Console.Commands.Term;
with Console.Commands.FS; use Console.Commands.FS;
with Console.Commands.Math; use Console.Commands.Math;
with Console.Commands.Graphics; use Console.Commands.Graphics;
with Console.Commands.Memory; use Console.Commands.Memory;
with File_System.RAM_Disk;
with Driver_Handler; use Driver_Handler;
with IO; use IO;

package body Console.Commands is
   function Call_Builtin (
      Command : Str_Ptr;
      Args : Arguments
   ) return Return_Data is
      procedure Print_Heap;
      pragma Import (C, Print_Heap, "print_heap");
   begin
      if Command = "keycode" then
         return Keycode (Args);
      elsif Command = "dh" then
         Print_Heap;
         return Ret_Void;
      elsif Command = "echo" then
         return Echo (Args);
      elsif Command = "dr" then
         File_System.RAM_Disk.Print_Disk;
         return Ret_Void;
      elsif Command = "shutdown" then
         Shutdown;
      elsif Command = "reboot" then
         Reboot;
      elsif Command = "time" then
         return Time (Args);
      elsif Command = "output" then
         return Redirect_Output (Args);
      elsif Command = "clear" then
         return Clear (Args);
      elsif Command = "color" then
         return Color (Args);
      elsif Command = "ll" then
         return List_Links (Args);
      elsif Command = "lnk" then
         return Link_Files (Args);
      elsif Command = "dlnk" then
         null;
      elsif Command = "edit" then
         null;
      elsif Command = "apnd" then
         return Append_To_File (Args);
      elsif Command = "apnd-raw" then
         return Append_Raw (Args);
      elsif Command = "write" then
         return Write_To_File (Args);
      elsif Command = "read" then
         return Read (Args);
      elsif Command = "new" then
         return New_File (Args);
      elsif Command = "jmp" then
         return Jump_To (Args);
      elsif Command = "del" then
         null;
      elsif Command = "info" then
         return Info (Args);
      elsif Command = "run" then
         return Run (Args);
      elsif Command = "+" then
         return Add (Args);
      elsif Command = "-" then
         return Subtract (Args);
      elsif Command = "*" then
         return Multiply (Args);
      elsif Command = "/" then
         return Divide (Args);
      elsif Command = "%" then
         return Modulus (Args);
      elsif Command = "draw" then
         return Draw (Args);
      elsif Command = "driver" then
         return Driver (Args);
      elsif Command = "poke" then
         return Poke (Args);
      elsif Command = "put" then
         return Put (Args);
      elsif Command = "baseconv" then
         return Base_Convert (Args);
      elsif Command = "format" then
         return Format (Args);
      elsif Command = "wait" then
         declare
            procedure Delay_Milliseconds (Time : Long_Integer);
            pragma Import (C, Delay_Milliseconds, "delay_ms");
         begin
            Delay_Milliseconds (Args (0).Int_Val);
         end;
      else
         Put_String ("Unknown command:", ' ');
         Put_String (Command.all);
      end if;

      return Ret_Fail;
   end Call_Builtin;
end Console.Commands;