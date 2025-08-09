with Lines; use Lines;
with File_System;
with File_System.Block;

package Console is
   --  Console is always at some position
   Current_Location : File_System.Block.File_Metadata;
   Current_Address : File_System.Storage_Address;

   procedure Read_Eval_Print_Loop;

   type Exec_Status is (Succeeded, Failed, Ongoing);
   function Execute_Command (
      To_Execute : Line
   ) return Exec_Status;

   type Value_Type is (Int, Str, Void);

   type Atom is record
      Value : Value_Type := Void;
      Int_Val : Long_Integer := 0;
      Str_Val : Line := (others => Null_Ch);
   end record;

   type Arguments is array (0 .. 15) of Atom;
   type Return_Data is record
      Value : Atom;
      Succeeded : Boolean;
   end record;

   Ret_Void : Return_Data := (
      (Void, 0, (others => Null_Ch)), True
   );

   Ret_Fail : Return_Data := (
      (Void, 0, (others => Null_Ch)), False
   );

private
   function Run_State return Exec_Status;
   function Run_Command return Return_Data;
end Console;