with Error_Handler; use Error_Handler;
with IO; use IO;

package body Console.Commands.Memory is
   function Poke (Args : Arguments) return Return_Data is
      function Poke_Byte (Address : Long_Integer) return Long_Integer;
      pragma Import (C, Poke_Byte, "poke_byte");
      function Poke_Word (Address : Long_Integer) return Long_Integer;
      pragma Import (C, Poke_Word, "poke_word");

      Result : Return_Data;
   begin
      Result.Succeeded := True;
      Result.Value.Value := Int;

      if Args (0).Str_Val = "byte" then
         Result.Value.Int_Val :=
            Poke_Byte (Args (1).Int_Val);
      elsif Args (0).Str_Val = "word" then
         Result.Value.Int_Val :=
            Poke_Word (Args (1).Int_Val);
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

      return Result;
   end Poke;
end Console.Commands.Memory;