with System;

package Error_Handler.Last_Chance is
   procedure Last_Chance_Handler
      (Source_Location : System.Address; Line : Integer);
   pragma Export (C, Last_Chance_Handler, "__gnat_last_chance_handler");
end Error_Handler.Last_Chance;