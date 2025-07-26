package RCheck is
   procedure CE_Index_Check;
   procedure CE_Invalid_Data;
   procedure CE_Stack_Overflow;

   pragma Export (C, CE_Index_Check, "__gnat_rcheck_CE_Index_Check");
   pragma Export (C, CE_Invalid_Data, "__gnat_rcheck_CE_Invalid_Data");
   pragma Export (C, CE_Stack_Overflow, "__gnat_rcheck_CE_Stack_Overflow");
end RCheck;