with Console;
with File_System.RAM_Disk;
with Terminal;

procedure Kernel is
begin
   File_System.RAM_Disk.Initialize;

   Terminal.Clear;
   Terminal.Do_Refresh := True;

   Console.Read_Eval_Print_Loop;

   loop
      null;
   end loop;
end Kernel;