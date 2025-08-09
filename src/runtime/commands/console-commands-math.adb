package body Console.Commands.Math is
   function Add (Args : Arguments) return Return_Data is
      Result : Return_Data;
   begin
      Result.Succeeded := True;
      Result.Value.Value := Int;
      Result.Value.Int_Val := Args (0).Int_Val + Args (1).Int_Val;

      return Result;
   end Add;

   function Subtract (Args : Arguments) return Return_Data is
      Result : Return_Data;
   begin
      Result.Succeeded := True;
      Result.Value.Value := Int;
      Result.Value.Int_Val := Args (0).Int_Val - Args (1).Int_Val;

      return Result;
   end Subtract;

   function Multiply (Args : Arguments) return Return_Data is
      Result : Return_Data;
   begin
      Result.Succeeded := True;
      Result.Value.Value := Int;
      Result.Value.Int_Val := Args (0).Int_Val * Args (1).Int_Val;

      return Result;
   end Multiply;

   function Divide (Args : Arguments) return Return_Data is
      Result : Return_Data;
   begin
      Result.Succeeded := True;
      Result.Value.Value := Int;
      Result.Value.Int_Val := Args (0).Int_Val / Args (1).Int_Val;

      return Result;
   end Divide;

   function Modulus (Args : Arguments) return Return_Data is
      Result : Return_Data;
   begin
      Result.Succeeded := True;
      Result.Value.Value := Int;
      Result.Value.Int_Val := Args (0).Int_Val mod Args (1).Int_Val;

      return Result;
   end Modulus;
end Console.Commands.Math;