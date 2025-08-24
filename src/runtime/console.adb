with IO; use IO;
with Lines.Converter;
with Console.Commands;
with Lines.List; use Lines.List;

package body Console is
   procedure Read_Eval_Print_Loop is
      To_Execute : Str_Ptr;
      List : Ch_List_Ptr;
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

         Put_String (">", ' ');

         List := Get_List (True);
         To_Execute := Make_Str (List);
         Free (List);

         New_Line;

         declare
            Status : Exec_Status := Execute_Command (To_Execute);
         begin
            Free (To_Execute);

            while Status = Ongoing loop
               Put_String ("...", ' ');

               List := Get_List (True);
               To_Execute := Make_Str (List);
               Free (List);

               New_Line;
               Status := Execute_Command (To_Execute);
               Free (To_Execute);
            end loop;

            if Status = Failed then
               Reset_State;
            end if;
         end;
      end loop;
   end Read_Eval_Print_Loop;

   type Exec_State is array (0 .. 127) of Str_Ptr;
   State : Exec_State := (others => Empty_Str);
   State_Index : Integer := 0;
   Current_State : Ch_List_Ptr := new Char_List;
   Depth : Integer := 0;
   Reading_Str : Boolean := False;
   Reading_Escape_Char : Boolean := False;
   function Execute_Command (To_Execute : Str_Ptr) return Exec_Status is
   begin
      for I in To_Execute'Range loop
         if Reading_Str then
            if Reading_Escape_Char then
               Append (
                  Current_State,
                  Escape_Char (
                     To_Execute (I)
                  )
               );
               Reading_Escape_Char := False;
            else
               if To_Execute (I) = '"' then
                  Reading_Str := False;
               elsif To_Execute (I) = '\' then
                  Reading_Escape_Char := True;
               else
                  Append (Current_State, To_Execute (I));
               end if;
            end if;
         else
            if Character'Pos (To_Execute (I)) >= 32 then
               case To_Execute (I) is
                  when '"' =>
                     Reading_Str := True;
                     Append (Current_State, '"');
                  when ';' =>
                     Depth := Depth - 1;

                     if not Empty (Current_State) then
                        Increment_State;
                     end if;

                     Append (Current_State, ';');

                     Increment_State;

                     if Depth = 0 then
                        return Run_State;
                     elsif Depth < 0 then
                        return Failed;
                     end if;
                  when ' ' =>
                     if not Empty (Current_State) then
                        Increment_State;
                     end if;
                  when others =>
                     if Empty (Current_State) then
                        case To_Execute (I) is
                           when '0' | '1' | '2' | '3' | '4'
                              | '5' | '6' | '7' | '8' | '9'
                              | '"' =>
                              null;
                           when others =>
                              Depth := Depth + 1;
                        end case;
                     end if;

                     Append (Current_State, To_Execute (I));
               end case;
            end if;
         end if;
      end loop;

      return Ongoing;
   end Execute_Command;

   procedure Increment_State is
   begin
      State (State_Index) := Make_Str (Current_State);
      State_Index := State_Index + 1;
      Free (Current_State);
      Current_State := new Char_List;
   end Increment_State;

   procedure Reset_State is
   begin
      for Part of State loop
         exit when Part = Empty_Str;
         Free (Part);
      end loop;

      State := (others => Empty_Str);
      State_Index := 0;
      Reading_Str := False;
      Depth := 0;
      Free (Current_State);
      Current_State := new Char_List;
   end Reset_State;

   function Run_State return Exec_Status is
      Data : Return_Data;
   begin
      State_Index := 0;

      Data := Run_Command;

      Reset_State;

      if Data.Succeeded then
         case Data.Value.Value is
            when Void =>
               New_Line;
            when Int =>
               Put_Int (Data.Value.Int_Val);
               New_Line;
            when Str =>
               Put_String (Data.Value.Str_Val.all);
         end case;
         return Succeeded;
      else
         return Failed;
      end if;
   end Run_State;

   function Run_Command return Return_Data is
      I : Integer := State_Index;
      Args : Arguments := (others => (Void, 0, Empty_Str));
      Command : Str_Ptr;
      Arg_I : Integer := 0;
   begin
      Command := State (I);
      I := I + 1;

      while I in State'Range loop
         case State (I) (1) is
            when '0' | '1' | '2' | '3' | '4'
               | '5' | '6' | '7' | '8' | '9' =>
               Args (Arg_I).Value := Int;
               Args (Arg_I).Int_Val := Lines.Converter.Str_To_Unknown_Base (
                  State (I)
               );
               Arg_I := Arg_I + 1;
            when '"' =>
               Args (Arg_I).Value := Str;
               Args (Arg_I).Str_Val := Substring (State (I), 2);
               Arg_I := Arg_I + 1;
            when ';' =>
               State_Index := I;

               declare
                  Data : constant Return_Data :=
                     Console.Commands.Call_Builtin (Command, Args);
               begin
                  Free_Args (Args);
                  return Data;
               end;
            when others =>
               State_Index := I;

               declare
                  Data : Return_Data := Run_Command;
               begin
                  if not Data.Succeeded then
                     if Data.Value.Value = Str then
                        Free (Data.Value.Str_Val);
                     end if;

                     Free_Args (Args);

                     return Ret_Fail;
                  end if;

                  Args (Arg_I) := Data.Value;
               end;

               Arg_I := Arg_I + 1;

               I := State_Index;
         end case;

         I := I + 1;
      end loop;

      Free_Args (Args);

      return Ret_Fail;
   end Run_Command;

   function Escape_Char (Suffix : Character) return Character is
   begin
      case Suffix is
         when '\' =>
            return '\';
         when '"' =>
            return '"';
         when 'n' =>
            return Character'Val (10);
         when 'r' =>
            return Character'Val (13);
         when 'e' =>
            return IO.ESC;
         when others =>
            return Suffix;
      end case;
   end Escape_Char;

   procedure Free_Args (Args : in out Arguments) is
   begin
      for Arg of Args loop
         if Arg.Value = Str then
            Free (Arg.Str_Val);
         end if;
      end loop;
   end Free_Args;
end Console;