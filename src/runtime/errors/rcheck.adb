with IO;
package body RCheck is
   procedure CE_Index_Check is
   begin
      loop
         IO.Put_Char ('X');
      end loop;
   end CE_Index_Check;

   procedure CE_Invalid_Data is
   begin
      loop
         IO.Put_Char ('Y');
      end loop;
   end CE_Invalid_Data;

   procedure CE_Stack_Overflow is
   begin
      loop
         IO.Put_Char ('Z');
      end loop;
   end CE_Stack_Overflow;
end RCheck;