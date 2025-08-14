with System.Unsigned_Types; use System.Unsigned_Types;

package Error_Handler.Traps is
   procedure Handle_Trap (
      Cause : Long_Long_Unsigned;
      Exception_PC : Long_Unsigned;
      Trap_Value : Long_Long_Unsigned;
      Status : Long_Long_Unsigned
   );
   pragma Export (C, Handle_Trap, "_handle_trap");
end Error_Handler.Traps;