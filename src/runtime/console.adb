with File_System.Block;
with IO; use IO;
with Lines.Scanner;
with File_System.RAM_Disk;
with File_System;
with File_System.Block.Util; use File_System.Block.Util;
with Bitwise; use Bitwise;

package body Console is
   Current_Location : File_System.Block.File_Metadata;
   Current_Address : File_System.Storage_Address := 3;

   procedure Read_Eval_Print_Loop is
      To_Execute : Lines.Line := (others => Character'Val (0));
   begin
      Current_Location := File_System.Block.Parse_File_Metadata
         (File_System.Root);

      loop
         for Index in Current_Location.Name'Range loop
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
      Arguments : Line;
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
         List_Links;
      elsif Command.Result = Make_Line ("cnt") then
         null;
      elsif Command.Result = Make_Line ("edit") then
         null;
      elsif Command.Result = Make_Line ("read") then
         null;
      elsif Command.Result = Make_Line ("new") then
         New_File (Arguments);
      elsif Command.Result = Make_Line ("jmp") then
         Jump_To (Arguments);
      else
         Put_String ("Unknown command:", ' ');
         Put_Line (Command.Result);
      end if;
   end Execute_Command;

   procedure List_Links is
   begin
      if Current_Location.Num_Links = 0 then
         Put_String ("This file doesn't link to anything! :P");
      else
         for Index in 0 .. Natural (Current_Location.Num_Links) - 1 loop
            Put_Line (Get_File_Name_Line
               (Current_Location.Links (Index).Address)
            );
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

      File_System.Write_Block (
         Address,
         File_System.Block.Make_File_Metadata (Metadata)
      );

      Current_Location.Links
         (Natural (Current_Location.Num_Links))
         .Address := Address;
      Current_Location.Num_Links := Current_Location.Num_Links + 1;

      File_System.Write_Block (
         Current_Address,
         File_System.Block.Make_File_Metadata (Current_Location)
      );
   end New_File;

   procedure Jump_To (Arguments : Line) is
      Scan : Lines.Scanner.Scan_Result;
      Curr_FN : Line;
   begin
      Scan := Lines.Scanner.Scan_To_Char (Arguments, 1, ' ');

      if Current_Location.Num_Links /= 0 then
         for Index in 0 .. Natural (Current_Location.Num_Links) - 1 loop
            Curr_FN := Get_File_Name_Line (
               Current_Location.Links (Index).Address
            );

            if Scan.Result = Curr_FN then
               Current_Address := Current_Location.Links (Index).Address;
               Current_Location := File_System.Block.Parse_File_Metadata (
                  File_System.Get_Block (Current_Address)
               );

               return;
            end if;
         end loop;
      end if;

      Put_String ("Invalid file");
   end Jump_To;
end Console;