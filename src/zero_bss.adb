with System; use System;
with System.Storage_Elements; use System.Storage_Elements;
with System.Machine_Code; use System.Machine_Code;

procedure Zero_BSS is
   function Get_BSS_Start return System.Address;
   pragma Import (C, Get_BSS_Start, "get_bss_start");

   function Get_BSS_End return System.Address;
   pragma Import (C, Get_BSS_End, "get_bss_end");

   Pointer   : Address := Get_BSS_Start;
   BSS_End   : constant Address := Get_BSS_End;
begin
   while Pointer < BSS_End loop
      Asm ("sb zero, 0(%0)",
         Inputs  => (Address'Asm_Input ("r", Pointer)),
         Volatile => True);

      Pointer := Pointer + 1;
   end loop;
end Zero_BSS;