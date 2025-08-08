with File_System.Block;
with IO; use IO;
with Lines.Scanner;
with File_System.RAM_Disk;
with File_System;
with Bitwise; use Bitwise;
with Lines.Converter;
with System; use System;
with Ada.Unchecked_Conversion;
with System.Machine_Code;
with Driver_Handler; use Driver_Handler;
with Terminal;
with Renderer;

package body Console is
   --  Console is always at some position
   Current_Location : File_System.Block.File_Metadata;
   Current_Address : File_System.Storage_Address;

   procedure Read_Eval_Print_Loop is
      To_Execute : Lines.Line := (others => Character'Val (0));
   begin
      --  By default starting position is the root file
      Current_Address := File_System.Root_Address;
      Current_Location := File_System.Block.Parse_File_Metadata (
         File_System.Get_Block (Current_Address)
      );

      loop
         for Index in Current_Location.Name'Range loop
            exit when Current_Location.Name (Index) = Null_Ch;
            Put_Char (Current_Location.Name (Index));
         end loop;

         Put_String ("> ", Character'Val (0));
         To_Execute := Get_Line (True);
         New_Line;

         Execute_Command (To_Execute);
      end loop;
   end Read_Eval_Print_Loop;

   procedure Execute_Command (To_Execute : Line) is
      procedure Print_Heap;
      pragma Import (C, Print_Heap, "print_heap");
      Command : Lines.Scanner.Scan_Result;
      Arguments : Line := (others => Character'Val (0));
   begin
      Command := Lines.Scanner.Scan_To_Char (To_Execute, 1, ' ');
      Arguments := Substring (To_Execute, Command.Scanner_Position);

      if Command.Result = Make_Line ("keycode") then
         Put_Int (Character'Pos (IO.Get_Char));
         New_Line;
      elsif Command.Result = Make_Line ("") then
         null;
      elsif Command.Result = Make_Line ("dh") then
         Print_Heap;
      elsif Command.Result = Make_Line ("echo") then
         Put_Line (Arguments);
      elsif Command.Result = Make_Line ("dr") then
         File_System.RAM_Disk.Print_Disk;
      elsif Command.Result = Make_Line ("ll") then
         List_Links (Arguments);
      elsif Command.Result = Make_Line ("lnk") then
         Link_Files (Arguments);
      elsif Command.Result = Make_Line ("dlnk") then
         null;
      elsif Command.Result = Make_Line ("edit") then
         null;
      elsif Command.Result = Make_Line ("apnd") then
         Append_To_File (Arguments);
      elsif Command.Result = Make_Line ("apnd-raw") then
         Append_To_File (
            (1 => Character'Val (
               Lines.Converter.Line_To_Long_Int (Arguments)
            ), others => Null_Ch),
            1
         );
      elsif Command.Result = Make_Line ("write") then
         Write_To_File (Arguments);
      elsif Command.Result = Make_Line ("read") then
         Read (Arguments);
      elsif Command.Result = Make_Line ("desc") then
         null;
      elsif Command.Result = Make_Line ("new") then
         New_File (Arguments);
      elsif Command.Result = Make_Line ("jmp") then
         Jump_To (Arguments);
      elsif Command.Result = Make_Line ("del") then
         null;
      elsif Command.Result = Make_Line ("info") then
         Info (Arguments);
      elsif Command.Result = Make_Line ("run") then
         Run (Arguments);
      elsif Command.Result = Make_Line ("test") then
         Test;
      elsif Command.Result = Make_Line ("shutdown") then
         Shutdown;
      elsif Command.Result = Make_Line ("reboot") then
         Reboot;
      elsif Command.Result = Make_Line ("time") then
         Time (Arguments);
      elsif Command.Result = Make_Line ("output") then
         Redirect_Output (Arguments);
      elsif Command.Result = Make_Line ("clear") then
         Terminal.Clear;
      elsif Command.Result = Make_Line ("color") then
         Terminal.Font_Color := Renderer.Color_Type (
            Lines.Converter.Line_To_Long_Int (Arguments)
         );
      elsif Command.Result = Make_Line ("background") then
         Terminal.Background_Color := Renderer.Color_Type (
            Lines.Converter.Line_To_Long_Int (Arguments)
         );
      else
         Put_String ("Unknown command:", ' ');
         Put_Line (Command.Result);
      end if;
   end Execute_Command;

   procedure List_Links (Arguments : Line) is
      type Link_Selection_Type is (
         To, From, Category, Any
      );
      for Link_Selection_Type use (
         To => 0,
         From => 1,
         Category => 2,
         Any => 3
      );
      Selection : Link_Selection_Type;
      CL : File_System.Block.File_Metadata renames Current_Location;
   begin
      --  determine link selection from argument
      if Arguments = Make_Line ("") then
         Selection := To;
      elsif Arguments = Make_Line ("to") then
         Selection := To;
      elsif Arguments = Make_Line ("from") then
         Selection := From;
      elsif Arguments = Make_Line ("category") then
         Selection := Category;
      elsif Arguments = Make_Line ("any") then
         Selection := Any;
      elsif Arguments = Make_Line ("all") then
         Selection := Any;
      else
         Put_String ("Invalid link type");
         return;
      end if;

      --  loop through links
      if CL.Num_Links = 0 then
         Put_String ("File has no links");
      else
         for Index in 0 .. Natural (CL.Num_Links) - 1 loop
            --  if link isn't right type, skip to Loop_End
            if Selection /= Any then
               declare
                  Selection_Byte : Byte;
               begin
                  Selection_Byte := Byte (
                     Link_Selection_Type'Pos (Selection)
                  );

                  if Selection_Byte /= CL.Links (Index).Link_Type then
                     goto Loop_End;
                  end if;
               end;
            end if;

            Put_Line (Get_File_Name_Line (CL.Links (Index).Address));
            <<Loop_End>>
         end loop;
      end if;
   end List_Links;

   procedure New_File (Arguments : Line) is
      Metadata : File_System.Block.File_Metadata;
      Address : constant File_System.Storage_Address
         := File_System.Get_Free_Address;
      Scan : Lines.Scanner.Scan_Result;
   begin
      Scan := Lines.Scanner.Scan_To_Char (Arguments, 1, ' ');
      Metadata.Name := Line_To_File_Name (Scan.Result);

      Metadata.Num_Links := 1;
      Metadata.Links (0).Address := Current_Address;
      Metadata.Links (0).Link_Type := 1;

      Write_File (Address, Metadata);

      Current_Location.Links
         (Natural (Current_Location.Num_Links))
         .Address := Address;
      Current_Location.Num_Links := Current_Location.Num_Links + 1;

      Write_File (Current_Address, Current_Location);
   end New_File;

   procedure Jump_To (Arguments : Line) is
      Result : Search_Result;
   begin
      Result := Get_File_From_Path (Current_Location, Arguments);

      if not Result.Found_Result then
         Put_String ("Path doesn't exist");
      else
         Current_Location := Result.File;
         Current_Address := Result.Address;
      end if;
   end Jump_To;

   procedure Link_Files (Arguments : Line) is
      Target : Search_Result;
      Container : File_System.Block.Link_Container;
   begin
      Target := Get_File_From_Path (Current_Location, Arguments);

      if not Target.Found_Result then
         Put_String ("Path doesn't exist");
         return;
      end if;

      Container.Address := Target.Address;
      Container.Link_Type := 0;
      Current_Location := Add_Link (Current_Location, Container);

      Container.Address := Current_Address;
      Container.Link_Type := 1;
      Target.File := Add_Link (Target.File, Container);

      Write_File (Target.Address, Target.File);
      Write_File (Current_Address, Current_Location);
   end Link_Files;

   procedure Append_To_File (Text : Line) is
   begin
      Append_To_File (Text, Length (Text));
   end Append_To_File;

   procedure Append_To_File (Text : Line; Len : Natural) is
      Data : File_Bytes_Pointer;
   begin
      Data := new File_Bytes (0 .. Len - 1);
      for Index in 0 .. Len - 1 loop
         Data (Index) := Character'Pos (Text (Line_Index (Index + 1)));
      end loop;

      Write_Data_After_Bytes (
         Data, Natural (Current_Location.Size),
         Current_Location, Current_Address
      );

      Free (Data);
   end Append_To_File;

   procedure Write_To_File (Text : Line) is
      Data : File_Bytes_Pointer;
      Len : constant Natural := Length (Text);
   begin
      Data := new File_Bytes (0 .. Len - 1);
      for Index in 0 .. Len - 1 loop
         Data (Index) := Character'Pos (Text (Line_Index (Index + 1)));
      end loop;

      Write_Data_After_Bytes (
         Data, 0,
         Current_Location, Current_Address
      );

      Free (Data);
   end Write_To_File;

   procedure Run (Arguments : Line) is
      Argument : Lines.Scanner.Scan_Result;
      Code : File_Bytes_Pointer;
   begin
      Argument := Lines.Scanner.Scan_To_Char (Arguments, 1, ' ');
      Code := Read_Into_Memory (Current_Location);

      if Argument.Result = Make_Line ("shell") then
         Run_Shell (Code);
      elsif Argument.Result = Make_Line ("asm") then
         Run_Assembly (Code);
      elsif Argument.Result = Make_Line ("") then
         Put_String ("Must specify type");
      else
         Put_String ("Unknown file type");
      end if;

      Free (Code);
   end Run;

   procedure Run_Shell (Code : File_Bytes_Pointer) is
      Command : Line := (others => Null_Ch);
      Command_Pos : Line_Index := 1;
   begin
      for Index in Code'Range loop
         if Code (Index) = 10 then
            Execute_Command (Command);
            Command := (others => Null_Ch);
            Command_Pos := 1;
         else
            Command (Command_Pos) := Character'Val (Code (Index));
            Command_Pos := Command_Pos + 1;
         end if;
      end loop;

      if Command (1) /= Null_Ch then
         Execute_Command (Command);
      end if;
   end Run_Shell;

   procedure Run_Assembly (Code : File_Bytes_Pointer) is
      type Proc_Type is access procedure;
      pragma Convention (C, Proc_Type);

      function To_Proc_Type is
         new Ada.Unchecked_Conversion (Address, Proc_Type);

      P : constant Proc_Type := To_Proc_Type (Code'Address);
   begin
      System.Machine_Code.Asm (
         "fence.i",
         Clobber => "memory",
         Volatile => True
      );

      P.all;
   end Run_Assembly;

   procedure Test is
      type Proc_Type is access procedure;
      pragma Convention (C, Proc_Type);
      function To_Proc is
         new Ada.Unchecked_Conversion (Address, Proc_Type);

      --  Allocate space and write one instruction
      Ptr : File_Bytes_Pointer := new File_Bytes (0 .. 3);
   begin
      Ptr (0) := 16#00#;
      Ptr (1) := 16#00#;
      Ptr (2) := 16#67#;
      Ptr (3) := 16#80#; --  This is `ret`

      --  Fence.i to synchronize the instruction cache
      System.Machine_Code.Asm (
         "fence.i",
         Clobber => "memory",
         Volatile => True
      );

      --  Run
      To_Proc (Ptr'Address).all;
   end Test;

   procedure Read (Arguments : Line) is
      Reading : File_Bytes_Pointer := Read_Into_Memory (
         Current_Location
      );
   begin
      if Arguments = Make_Line ("") then
         for Index in Reading'Range loop
            Put_Char (Integer (Reading (Index)));
         end loop;
      elsif Arguments = Make_Line ("bytes") then
         for Index in Reading'Range loop
            Put_Int (Long_Integer (Reading (Index)));
            Put_Char (' ');
         end loop;
      else
         Put_String ("Invalid option", Null_Ch);
      end if;

      Put_Char (10);

      Free (Reading);
   end Read;

   procedure Info (Arguments : Line) is
   begin
      if Arguments = Make_Line ("size") then
         Put_Int (Long_Integer (Current_Location.Size));
         Put_String ("B");
      elsif Arguments = Make_Line ("addr") then
         Put_Int (Long_Integer (Current_Address));
         New_Line;
      elsif Arguments = Make_Line ("data-addr") then
         Put_Int (Long_Integer (Current_Location.Data_Start));
         New_Line;
      elsif Arguments = Make_Line ("desc-addr") then
         Put_Int (Long_Integer (Current_Location.Description_Start));
         New_Line;
      elsif Arguments = Make_Line ("num-links") then
         Put_Int (Long_Integer (Current_Location.Num_Links));
         Put_String (" links");
      elsif Arguments = Make_Line ("attributes") then
         Put_Int (Long_Integer (Current_Location.Num_Links));
         New_Line;
      else
         Put_String ("Invalid option");
      end if;
   end Info;

   procedure Time (Arguments : Line) is
      function Tick_Time return Long_Integer;
      pragma Import (C, Tick_Time, "tick_time");
      function Cycle_Time return Long_Integer;
      pragma Import (C, Cycle_Time, "cycle_time");
   begin
      if Arguments = Make_Line ("tick") then
         Put_Int (Tick_Time);
         New_Line;
      elsif Arguments = Make_Line ("cycle") then
         Put_Int (Cycle_Time);
         New_Line;
      elsif Arguments = Make_Line ("date") then
         Put_Int (Long_Integer (RTC_Year));
         Put_Char ('/');
         Put_Int (Long_Integer (RTC_Day));
         Put_Char ('/');
         Put_Int (Long_Integer (RTC_Month));
         New_Line;
      elsif Arguments = Make_Line ("time") then
         Put_Int (Long_Integer (RTC_Hours));
         Put_Char (':');
         Put_Int (Long_Integer (RTC_Minutes));
         Put_Char (':');
         Put_Int (Long_Integer (RTC_Seconds));
         New_Line;
      elsif Arguments = Make_Line ("hour") then
         Put_Int (Long_Integer (RTC_Hours));
         New_Line;
      elsif Arguments = Make_Line ("minute") then
         Put_Int (Long_Integer (RTC_Minutes));
         New_Line;
      elsif Arguments = Make_Line ("second") then
         Put_Int (Long_Integer (RTC_Seconds));
         New_Line;
      else
         Put_String ("Invalid option");
      end if;
   end Time;

   procedure Redirect_Output (Arguments : Line) is
   begin
      if Arguments = Make_Line ("uart") then
         Main_Stream.Output := UART;
      elsif Arguments = Make_Line ("terminal") then
         Main_Stream.Output := Term;
      else
         Put_String ("Invalid option");
      end if;
   end Redirect_Output;
end Console;