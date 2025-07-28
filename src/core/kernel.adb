with Console;
with File_System.RAM_Disk;

procedure Kernel is
begin
   File_System.RAM_Disk.Initialize;

   Console.Read_Eval_Print_Loop;

   loop
      null;
   end loop;
end Kernel;