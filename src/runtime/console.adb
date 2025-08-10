with IO; use IO;
with Lines.Converter;
with Console.Commands;

package body Console is
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

         Put_String (">", ' ');
         To_Execute := Get_Line (True);
         New_Line;

         while Execute_Command (To_Execute) = Ongoing loop
            Put_String ("...", ' ');
            To_Execute := Get_Line (True);
            New_Line;
         end loop;
      end loop;
   end Read_Eval_Print_Loop;

   type Exec_State is array (0 .. 127) of Line;
   State : Exec_State := (others => (others => Null_Ch));
   State_Index : Integer := 0;
   Token_Index : Line_Index := 1;
   Depth : Integer := 0;
   Reading_Str : Boolean := False;
   Reading_Escape_Char : Boolean := False;
   function Execute_Command (To_Execute : Line) return Exec_Status is
   begin
      for I in To_Execute'Range loop
         if Reading_Str then
            if Reading_Escape_Char then
               State (State_Index) (Token_Index) := Escape_Char (
                  To_Execute (I)
               );
               Token_Index := Token_Index + 1;
               Reading_Escape_Char := False;
            else
               if To_Execute (I) = '"' then
                  Reading_Str := False;
               elsif To_Execute (I) = '\' then
                  Reading_Escape_Char := True;
               else
                  State (State_Index) (Token_Index) := To_Execute (I);
                  Token_Index := Token_Index + 1;
               end if;
            end if;
         else
            if Character'Pos (To_Execute (I)) >= 32 then
               case To_Execute (I) is
                  when '"' =>
                     Reading_Str := True;
                     State (State_Index) (Token_Index) := '"';
                     Token_Index := Token_Index + 1;
                  when ';' =>
                     Depth := Depth - 1;

                     if Token_Index /= 1 then
                        State_Index := State_Index + 1;
                     end if;

                     State (State_Index) (1) := ';';

                     State_Index := State_Index + 1;
                     Token_Index := 1;

                     if Depth = 0 then
                        return Run_State;
                     elsif Depth < 0 then
                        return Failed;
                     end if;
                  when ' ' =>
                     if Token_Index /= 1 then
                        State_Index := State_Index + 1;
                        Token_Index := 1;
                     end if;
                  when others =>
                     if Token_Index = 1 then
                        case To_Execute (I) is
                           when '0' | '1' | '2' | '3' | '4'
                              | '5' | '6' | '7' | '8' | '9'
                              | '"' =>
                              null;
                           when others =>
                              Depth := Depth + 1;
                        end case;
                     end if;

                     State (State_Index) (Token_Index) := To_Execute (I);
                     Token_Index := Token_Index + 1;
               end case;
            end if;
         end if;
      end loop;

      return Ongoing;
   end Execute_Command;

   function Run_State return Exec_Status is
      Data : Return_Data;
   begin
      State_Index := 0;

      Data := Run_Command;

      State := (others => (others => Null_Ch));
      State_Index := 0;
      Token_Index := 1;
      Reading_Str := False;
      Depth := 0;

      if Data.Succeeded then
         case Data.Value.Value is
            when Void =>
               New_Line;
            when Int =>
               Put_Int (Data.Value.Int_Val);
               New_Line;
            when Str =>
               Put_Line (Data.Value.Str_Val);
         end case;
         return Succeeded;
      else
         return Failed;
      end if;
   end Run_State;

   function Run_Command return Return_Data is
      I : Integer := State_Index;
      Args : Arguments;
      Command : Line;
      Arg_I : Integer := 0;
   begin
      Command := State (I);
      I := I + 1;

      while I in State'Range loop
         case State (I) (1) is
            when '0' | '1' | '2' | '3' | '4'
               | '5' | '6' | '7' | '8' | '9' =>
               Args (Arg_I).Value := Int;
               Args (Arg_I).Int_Val := Lines.Converter.Line_To_Long_Int (
                  State (I)
               );
               Arg_I := Arg_I + 1;
            when '"' =>
               Args (Arg_I).Value := Str;
               Args (Arg_I).Str_Val := Substring (State (I), 2);
               Arg_I := Arg_I + 1;
            when ';' =>
               State_Index := I;

               return Console.Commands.Call_Builtin (Command, Args);
            when others =>
               State_Index := I;

               declare
                  Data : constant Return_Data := Run_Command;
               begin
                  if not Data.Succeeded then
                     return Ret_Fail;
                  end if;

                  Args (Arg_I) := Data.Value;
               end;

               Arg_I := Arg_I + 1;

               I := State_Index;
         end case;

         I := I + 1;
      end loop;

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
         when others =>
            return Suffix;
      end case;
   end Escape_Char;
end Console;