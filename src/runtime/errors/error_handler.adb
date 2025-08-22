with IO; use IO;
with Terminal;
with Driver_Handler;

package body Error_Handler is
   procedure Throw (Error_Message : Lines.Line; File_Name : Lines.Line) is
   begin
      Put_Char (ESC);
      Put_String ("[31m", '(');
      Put_Line (File_Name, Character'Val (0));
      Put_String (") ", Character'Val (0));
      Put_Line (Error_Message, Character'Val (0));
      Put_Char (ESC);
      Put_String ("[0m");
   end Throw;

   procedure String_Throw (Error_Message : String; File_Name : String) is
   begin
      Put_Char (ESC);
      Put_String ("[31m", '(');
      Put_String (File_Name, Character'Val (0));
      Put_String (") ", Character'Val (0));
      Put_String (Error_Message, Character'Val (0));
      Put_Char (ESC);
      Put_String ("[0m");
   end String_Throw;

   procedure Throw (Error : Builtin_Error) is
   begin
      Error_ESC_Code;

      case Error.Level is
         when OS =>
            Terminal.Clear;
            Put_String ("SYSTEM ERROR! This should not have occurred!");
         when User | Driver =>
            null;
      end case;

      case Error.Kind is
         when Instruction_Addr_Misaligned =>
            Put_String ("Trap Occurred: Instruction Address Misaligned");
         when Instruction_Addr_Fault =>
            Put_String ("Trap Occurred: Instruction Address Fault");
         when Illegal_Instruction =>
            Put_String ("Trap Occurred: Illegal Instruction");
         when Breakpoint =>
            Put_String ("Trap Occurred: Breakpoint");
         when Load_Address_Misaligned =>
            Put_String ("Trap Occurred: Load Address Misaligned");
         when Load_Access_Fault =>
            Put_String ("Trap Occurred: Load Access Fault");
         when Store_Addr_Misaligned =>
            Put_String ("Trap Occurred: Store/AMO Address Misaligned");
         when Store_Access_Fault =>
            Put_String ("Trap Occurred: Store/AMO Access Fault");
         when Env_Call_UMode =>
            Put_String ("Trap Occurred: Enviornment Call From U-Mode");
         when Env_Call_SMode =>
            Put_String ("Trap Occurred: Enviornment Call From S-Mode");
         when Instruction_Page_Fault =>
            Put_String ("Trap Occurred: Instruction Page Fault");
         when Load_Page_Fault =>
            Put_String ("Trap Occurred: Load Page Fault");
         when Reserved =>
            Put_String ("Trap Occurred: Reserved");
         when Store_Page_Fault =>
            Put_String ("Trap Occurred: Store/AMO Page Fault");
         when Unknown =>
            Put_String ("Unknown Error Occurred");
         when Unknown_Trap =>
            Put_String ("Unknown Trap Occurred");
         when Failed_Assertion =>
            Put_String ("Failed Assertion");
         when CrOS_EC_Error =>
            Put_String ("CrOS EC Error Occurred");
         when Invalid_Argument =>
            Put_String ("Invalid Argument Provided");
         when Incorrect_Type =>
            Put_String ("Incorrect Type");
      end case;

      Put_Line (Error.Message);

      Put_String ("Called by", ' ');
      Put_Line (Error.From, Null_Ch);

      case Error.Optional_Params is
         when No_Extra =>
            null;
         when On_Line =>
            Put_String (" on line", ' ');
            Put_Int (Long_Integer (Error.On_Line));
      end case;

      New_Line;

      Reset_ESC_Code;

      if Error.Level = OS then
         Warning_ESC_Code;
         Put_String (
            "Press (c) to continue, (s) to shutdown, or (r) to reboot"
         );
         Reset_ESC_Code;

         declare
            Input : Character;
         begin
            loop
               Input := Get_Char;

               case Input is
                  when 'c' =>
                     exit;
                  when 's' =>
                     Driver_Handler.Shutdown;
                  when 'r' =>
                     Driver_Handler.Reboot;
                  when others =>
                     null;
               end case;
            end loop;
         end;
      end if;
      Reset_ESC_Code;
   end Throw;

   function Assert (
      Condition : Boolean;
      Fail_Message : Line;
      Location : Line
   ) return Boolean is
   begin
      if not Condition then
         Throw ((
            Kind => Failed_Assertion,
            Message => Fail_Message,
            From => Location,
            Optional_Params => No_Extra,
            On_Line => 0,
            Level => User));
      end if;

      return Condition;
   end Assert;

   procedure Error_ESC_Code is
   begin
      Put_Char (ESC);
      Put_String ("[31", 'm');
   end Error_ESC_Code;

   procedure Warning_ESC_Code is
   begin
      Put_Char (ESC);
      Put_String ("[33", 'm');
   end Warning_ESC_Code;

   procedure Reset_ESC_Code is
   begin
      Put_Char (ESC);
      Put_String ("[0", 'm');
   end Reset_ESC_Code;
end Error_Handler;