with Lines; use Lines;

package Error_Handler is
   type Error_Type is (
      Unknown,
      Failed_Assertion,
      --  trap errors
      Instruction_Addr_Misaligned,
      Instruction_Addr_Fault,
      Illegal_Instruction,
      Breakpoint,
      Load_Address_Misaligned,
      Load_Access_Fault,
      Store_Addr_Misaligned,
      Store_Access_Fault,
      Env_Call_UMode,
      Env_Call_SMode,
      Instruction_Page_Fault,
      Load_Page_Fault,
      Reserved,
      Store_Page_Fault,
      Unknown_Trap,
      CrOS_EC_Error
   );
   type Optional_Params_Type is (
      No_Extra, On_Line
   );
   type Error_Level is (
      OS, Driver, User
   );
   type Builtin_Error is record
      Kind : Error_Type;
      Message : Line;
      From : Line;
      On_Line : Natural;
      Optional_Params : Optional_Params_Type;
      Level : Error_Level;
   end record;

   procedure Throw (Error : Builtin_Error);
   procedure Throw (Error_Message : Lines.Line; File_Name : Lines.Line);
   procedure String_Throw (Error_Message : String; File_Name : String);
   pragma Export (C, Throw, "_throw_error");

   function Assert (
      Condition : Boolean;
      Fail_Message : Line;
      Location : Line
   ) return Boolean;

private
   procedure Error_ESC_Code;
   procedure Warning_ESC_Code;
   procedure Reset_ESC_Code;
end Error_Handler;