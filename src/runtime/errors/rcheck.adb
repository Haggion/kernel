with Error_Handler; use Error_Handler;
package body RCheck is
   procedure CE_Index_Check is
   begin
      loop
         String_Throw ("Index out of range", "rcheck.adb");
      end loop;
   end CE_Index_Check;

   procedure CE_Invalid_Data is
   begin
      loop
         String_Throw ("Invalid data", "rcheck.adb");
      end loop;
   end CE_Invalid_Data;

   procedure CE_Stack_Overflow is
   begin
      loop
         String_Throw ("Stack overflow", "rcheck.adb");
      end loop;
   end CE_Stack_Overflow;
end RCheck;