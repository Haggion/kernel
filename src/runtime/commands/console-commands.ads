package Console.Commands is
   function Call_Builtin (
      Command : Str_Ptr;
      Args : Arguments
   ) return Return_Data;
end Console.Commands;