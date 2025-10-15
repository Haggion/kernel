with File_System.Block;
with IO; use IO;
with File_System;
with Bitwise; use Bitwise;
with System; use System;
with Ada.Unchecked_Conversion;
with System.Machine_Code;
with Error_Handler; use Error_Handler;
with File_System.Formatter;

package body Console.Commands.FS is
   function List_Links (Args : Arguments) return Return_Data is
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
      if Args (0).Str_Val = null then
         Selection := To;
      elsif Args (0).Str_Val = "to" then
         Selection := To;
      elsif Args (0).Str_Val = "from" then
         Selection := From;
      elsif Args (0).Str_Val = "category" then
         Selection := Category;
      elsif Args (0).Str_Val = "any" then
         Selection := Any;
      elsif Args (0).Str_Val = "all" then
         Selection := Any;
      else
         Put_String ("Invalid link type");
         return Ret_Fail;
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

      return Ret_Void;
   end List_Links;

   function New_File (Args : Arguments) return Return_Data is
      Metadata : File_System.Block.File_Metadata;
      Address : constant File_System.Storage_Address
         := File_System.Get_Free_Address;
   begin
      if Args (0).Str_Val = null then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for file name"),
            Make_Line ("Console.Commands.FS#New_File"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      Metadata.Name := Str_To_File_Name (Args (0).Str_Val);

      Metadata.Num_Links := 1;
      Metadata.Links (0).Address := Current_Address;
      Metadata.Links (0).Link_Type := 1;

      Write_File (Address, Metadata);

      Current_Location.Links
         (Natural (Current_Location.Num_Links))
         .Address := Address;
      Current_Location.Num_Links := Current_Location.Num_Links + 1;

      Write_File (Current_Address, Current_Location);

      return Ret_Void;
   end New_File;

   function Jump_To (Args : Arguments) return Return_Data is
      Result : Search_Result;
   begin
      if Args (0).Str_Val = null then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for path"),
            Make_Line ("Console.Commands.FS#Jump_To"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      Result := Get_File_From_Path (Current_Location, Args (0).Str_Val);

      if not Result.Found_Result then
         Put_String ("Path doesn't exist");

         return Ret_Fail;
      else
         Current_Location := Result.File;
         Current_Address := Result.Address;
      end if;

      return Ret_Void;
   end Jump_To;

   function Link_Files (Args : Arguments) return Return_Data is
      Target : Search_Result;
      Container : File_System.Block.Link_Container;
   begin
      if Args (0).Str_Val = null then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for path"),
            Make_Line ("Console.Commands.FS#Link_Files"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      Target := Get_File_From_Path (Current_Location, Args (0).Str_Val);

      if not Target.Found_Result then
         Put_String ("Path doesn't exist");
         return Ret_Fail;
      end if;

      Container.Address := Target.Address;
      Container.Link_Type := 0;
      Current_Location := Add_Link (Current_Location, Container);

      Container.Address := Current_Address;
      Container.Link_Type := 1;
      Target.File := Add_Link (Target.File, Container);

      Write_File (Target.Address, Target.File);
      Write_File (Current_Address, Current_Location);

      return Ret_Void;
   end Link_Files;

   function Append_To_File (Args : Arguments) return Return_Data is
   begin
      if Args (0).Value /= Str then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for input"),
            Make_Line ("Console.Commands.FS#Append_To_File"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      return Append_To_File (
         Args (0).Str_Val,
         Args (0).Str_Val'Length
      );
   end Append_To_File;

   function Append_To_File
   (
      Text : Str_Ptr;
      Len : Natural
   ) return Return_Data is
      Data : File_Bytes_Pointer;
   begin
      Data := new File_Bytes (0 .. Len - 1);
      for Index in 0 .. Len - 1 loop
         Data (Index) := Character'Pos (Text (Index + 1));
      end loop;

      Write_Data_After_Bytes (
         Data, Natural (Current_Location.Size),
         Current_Location, Current_Address
      );

      Free (Data);

      return Ret_Void;
   end Append_To_File;

   function Append_Raw (Args : Arguments) return Return_Data is
      Append_Result : Return_Data;
      Temp : Str_Ptr;
   begin
      for Arg of Args loop
         exit when Arg.Value /= Int;

         --  if Arg.Int_Val < 255 then
         --     Temp := new Lines.Str (1 .. 1);
         --     Temp (1) := Character'Val (Arg.Int_Val);
         --  else
         declare
            Bytes : constant Four_Byte_Array := Four_Bytes_To_Bytes (
               Four_Bytes (Arg.Int_Val)
            );
         begin
            Temp := new Lines.Str (1 .. 4);

            Temp (4) := Character'Val (Bytes (0));
            Temp (3) := Character'Val (Bytes (1));
            Temp (2) := Character'Val (Bytes (2));
            Temp (1) := Character'Val (Bytes (3));
         end;
         --  end if;

         Append_Result := Append_To_File (
            Temp,
            Temp'Length
         );

         Free (Temp);

         if not Append_Result.Succeeded then
            return Ret_Fail;
         end if;
      end loop;

      return Ret_Void;
   end Append_Raw;

   function Write_To_File (Args : Arguments) return Return_Data is
      Data : File_Bytes_Pointer;
      Text : Str_Ptr;
      Len : Natural;
   begin
      if Args (0).Str_Val = null then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for input"),
            Make_Line ("Console.Commands.FS#Write_To_File"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      Text := Args (0).Str_Val;
      Len := Text'Length;

      Data := new File_Bytes (0 .. Len - 1);
      for Index in 0 .. Len - 1 loop
         Data (Index) := Character'Pos (Text (Index + 1));
      end loop;

      Write_Data_After_Bytes (
         Data, 0,
         Current_Location, Current_Address
      );

      Free (Data);

      return Ret_Void;
   end Write_To_File;

   function Run (Args : Arguments) return Return_Data is
      Code : File_Bytes_Pointer;
      Result : Return_Data := Ret_Fail;
   begin
      if Args (0).Str_Val = null then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for execution method"),
            Make_Line ("Console.Commands.FS#Run"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      Code := Read_Into_Memory (Current_Location);

      if Args (0).Str_Val = "shell" then
         Result := Run_Shell (Code);
      elsif Args (0).Str_Val = "asm" then
         Result := Run_Assembly (Code);
      else
         Put_String ("Unknown execution method");
      end if;

      Free (Code);

      return Result;
   end Run;

   function Run_Shell (Code : File_Bytes_Pointer) return Return_Data is
      Command : Line := (others => Null_Ch);
      Command_Pos : Line_Index := 1;
   begin
      for Index in Code'Range loop
         if Code (Index) = 10 then
            if Execute_Command (Make_Str (Command)) = Failed then
               return Ret_Fail;
            end if;
            Command := (others => Null_Ch);
            Command_Pos := 1;
         else
            Command (Command_Pos) := Character'Val (Code (Index));
            Command_Pos := Command_Pos + 1;
         end if;
      end loop;

      if Command (1) /= Null_Ch then
         if Execute_Command (Make_Str (Command)) = Failed then
            return Ret_Fail;
         end if;
      end if;

      return Ret_Void;
   end Run_Shell;

   function Run_Assembly (Code : File_Bytes_Pointer) return Return_Data is
      type Proc_Type is access procedure;
      pragma Convention (C, Proc_Type);

      function To_Proc_Type is
         new Ada.Unchecked_Conversion (Address, Proc_Type);

      P : constant Proc_Type := To_Proc_Type (Code.all'Address);
   begin
      System.Machine_Code.Asm (
         "fence.i",
         Clobber => "memory",
         Volatile => True
      );

      P.all;

      return Ret_Void;
   end Run_Assembly;

   function Read (Args : Arguments) return Return_Data is
      Reading : File_Bytes_Pointer := Read_Into_Memory (
         Current_Location
      );
   begin
      if Args (0).Str_Val = null then
         for Index in Reading'Range loop
            Put_Char (Integer (Reading (Index)));
         end loop;
      elsif Args (0).Str_Val = "bytes" then
         for Index in Reading'Range loop
            Put_Int (Long_Integer (Reading (Index)));
            Put_Char (' ');
         end loop;
      else
         Put_String ("Invalid option", Null_Ch);
      end if;

      Put_Char (10);

      Free (Reading);

      return Ret_Void;
   end Read;

   function Info (Args : Arguments) return Return_Data is
      Result : Return_Data;
   begin
      if Args (0).Str_Val = null then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected string argument for type of info"),
            Make_Line ("Console.Commands.FS#Info"),
            0, No_Extra, User
         ));
         return Ret_Fail;
      end if;

      Result.Succeeded := True;

      if Args (0).Str_Val = "size" then
         Result.Value.Value := Int;
         Result.Value.Int_Val := Long_Integer (Current_Location.Size);
      elsif Args (0).Str_Val = "addr" then
         Result.Value.Value := Int;
         Result.Value.Int_Val := Long_Integer (Current_Address);
      elsif Args (0).Str_Val = "data-addr" then
         Result.Value.Value := Int;
         Result.Value.Int_Val := Long_Integer (Current_Location.Data_Start);
      elsif Args (0).Str_Val = "num-links" then
         Result.Value.Value := Int;
         Result.Value.Int_Val := Long_Integer (Current_Location.Num_Links);
      elsif Args (0).Str_Val = "attributes" then
         Result.Value.Value := Int;
         Result.Value.Int_Val := Long_Integer (Current_Location.Attributes);
      else
         Put_String ("Invalid option");
         return Ret_Fail;
      end if;

      return Result;
   end Info;

   function Format (Args : Arguments) return Return_Data is
   begin
      File_System.Formatter.Format (
         Four_Bytes (Args (0).Int_Val)
      );
      return Ret_Void;
   end Format;
end Console.Commands.FS;