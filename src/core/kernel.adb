with Console;
with File_System.RAM_Disk;
with Terminal;
with IO; use IO;

procedure Kernel is
begin
   File_System.RAM_Disk.Initialize;

   Terminal.Clear;

   Put_String (
      " _                       _             " & ENDL &
      "| |                     (_)            " & ENDL &
      "| |__   __ _  __ _  __ _ _  ___  _ __  " & ENDL &
      "| '_ \ / _` |/ _` |/ _` | |/ _ \| '_ \ " & ENDL &
      "| | | | (_| | (_| | (_| | | (_) | | | |" & ENDL &
      "|_| |_|\__,_|\__, |\__, |_|\___/|_| |_|" & ENDL &
      "            __/ | __/ |                " & ENDL &
      "            |___/ |___/                "
   );

   Console.Read_Eval_Print_Loop;

   loop
      null;
   end loop;
end Kernel;