with IO; use IO;
with Lines.Converter; use Lines.Converter;

package body Error_Handler.Traps is
   procedure Handle_Trap (
      Cause : Long_Long_Unsigned;
      Exception_PC : Long_Unsigned;
      Trap_Value : Long_Long_Unsigned;
      Status : Long_Long_Unsigned
   ) is
      Trap_Type : Error_Type;
      Error : Builtin_Error;
      Message : aliased Line;
   begin
      case Cause is
         when 0 =>
            Trap_Type := Instruction_Addr_Misaligned;
         when 1 =>
            Trap_Type := Instruction_Addr_Fault;
         when 2 =>
            Trap_Type := Illegal_Instruction;
         when 3 =>
            Trap_Type := Breakpoint;
         when 4 =>
            Trap_Type := Load_Address_Misaligned;
         when 5 =>
            Trap_Type := Load_Access_Fault;
         when 6 =>
            Trap_Type := Store_Addr_Misaligned;
         when 7 =>
            Trap_Type := Store_Access_Fault;
         when 8 =>
            Trap_Type := Env_Call_UMode;
         when 9 =>
            Trap_Type := Env_Call_SMode;
         when 12 =>
            Trap_Type := Instruction_Page_Fault;
         when 13 =>
            Trap_Type := Load_Page_Fault;
         when 14 =>
            Trap_Type := Reserved;
         when 15 =>
            Trap_Type := Store_Page_Fault;
         when others =>
            Trap_Type := Unknown;

            Append_To_Line (
               Message'Access,
               Make_Line ("Error code: ")
            );
            Append_To_Line (
               Message'Access,
               Hex_To_Line (Cause)
            );
      end case;

      Error.From := Make_Line ("trap handler");
      Error.Kind := Trap_Type;
      Error.Level := OS;
      Error.Optional_Params := No_Extra;

      Append_To_Line (Message'Access, Make_Line ("PC: 0x"));
      Append_To_Line (
         Message'Access,
         Hex_To_Line (Long_Long_Unsigned (Exception_PC))
      );
      Append_New_Line (Message'Access);

      Append_To_Line (Message'Access, Make_Line ("Trap value: 0x"));
      Append_To_Line (
         Message'Access,
         Hex_To_Line (Trap_Value)
      );
      Append_New_Line (Message'Access);

      Append_To_Line (Message'Access, Make_Line ("Status register: 0x"));
      Append_To_Line (
         Message'Access,
         Hex_To_Line (Status)
      );

      Error.Message := Message;

      Throw (Error);
   end Handle_Trap;
end Error_Handler.Traps;