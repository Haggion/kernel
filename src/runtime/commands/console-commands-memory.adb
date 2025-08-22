with Error_Handler; use Error_Handler;
with IO; use IO;

package body Console.Commands.Memory is
   function Poke (Args : Arguments) return Return_Data is
      function Poke_Byte (Address : Long_Integer) return Long_Integer;
      pragma Import (C, Poke_Byte, "poke_byte");
      function Poke_Word (Address : Long_Integer) return Long_Integer;
      pragma Import (C, Poke_Word, "poke_word");
   begin
      if Args (0).Str_Val = Make_Line ("byte") then
         Put_Int (
            Poke_Byte (Args (1).Int_Val)
         );
      elsif Args (0).Str_Val = Make_Line ("word") then
         Put_Int (
            Poke_Word (Args (1).Int_Val)
         );
      else
         Throw (
            (
               Invalid_Argument,
               Make_Line ("Expected either byte or word for first argument"),
               Make_Line ("Poke command"),
               0,
               No_Extra,
               User
            )
         );

         return Ret_Fail;
      end if;

      return Ret_Void;
   end Poke;
end Console.Commands.Memory;