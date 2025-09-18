with Error_Handler; use Error_Handler;
with IO; use IO;

package body Console.Commands.Memory is
   function Poke (Args : Arguments) return Return_Data is
      function Poke_Byte (Address : Long_Integer) return Long_Integer;
      pragma Import (Ada, Poke_Byte, "poke_byte");
      function Poke_Word (Address : Long_Integer) return Long_Integer;
      pragma Import (Ada, Poke_Word, "poke_word");

      Result : Return_Data;
   begin
      if
         Args (0).Value /= Str or
         Args (1).Value /= Int
      then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected two arguments of type str, int"),
            Make_Line ("Poke command"),
            0,
            No_Extra,
            User
         ));

         return Ret_Fail;
      end if;

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

   function Put (Args : Arguments) return Return_Data is
      procedure Put_Byte (Address : Long_Integer; Value : Long_Integer);
      pragma Import (Ada, Put_Byte, "put_byte");
      procedure Put_Word (Address : Long_Integer; Value : Long_Integer);
      pragma Import (Ada, Put_Word, "put_word");
   begin
      if
         Args (0).Value /= Str or
         Args (1).Value /= Int or
         Args (2).Value /= Int
      then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected three arguments of type str, int, int"),
            Make_Line ("Put command"),
            0,
            No_Extra,
            User
         ));

         return Ret_Fail;
      end if;

      if Args (0).Str_Val = "byte" then
         Put_Byte (
            Args (1).Int_Val,
            Args (2).Int_Val
         );
      elsif Args (0).Str_Val = "word" then
         Put_Word (
            Args (1).Int_Val,
            Args (2).Int_Val
         );
      else
         Throw (
            (
               Invalid_Argument,
               Make_Line ("Expected either byte or word for first argument"),
               Make_Line ("Put command"),
               0,
               No_Extra,
               User
            )
         );

         return Ret_Fail;
      end if;

      return Ret_Void;
   end Put;
end Console.Commands.Memory;