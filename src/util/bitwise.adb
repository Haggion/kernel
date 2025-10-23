with System.Unsigned_Types; use System.Unsigned_Types;

package body Bitwise is
   function "and"(Left : Byte; Right : Integer) return Byte is
   begin
      return Byte (Left and Unsigned_8 (Right));
   end "and";

   function "and"(Left : Four_Bytes; Right : Integer) return Byte is
   begin
      return Byte (Left and Unsigned_32 (Right));
   end "and";

   function "or"(Left : Byte; Right : Integer) return Byte is
   begin
      return Byte (Left or Unsigned_8 (Right));
   end "or";

   function Get_Bit (Num : Byte; Bit : Natural) return Boolean is
   begin
      return (Num and Byte (2 ** Bit)) /= 0;
   end Get_Bit;

   function Set_Bit (Num : Byte; Bit : Natural; Value : Boolean) return Byte is
      Mask : constant Unsigned := 2 ** Bit;
   begin
      if Value then
         return Byte (Unsigned (Num) or Mask);
      end if;

      return Byte (Unsigned (Num) and not Mask);
   end Set_Bit;

   function Extract_Byte (Num : Four_Bytes) return Byte is
   begin
      return Num and 2#11111111#;
   end Extract_Byte;

   function Bytes_To_Four_Bytes (
      Byte1 : Byte;
      Byte2 : Byte;
      Byte3 : Byte;
      Byte4 : Byte
   ) return Four_Bytes is
      Result : Four_Bytes := Four_Bytes (Byte4);
   begin
      Result := Result + Four_Bytes (Byte3) * 2 ** 8;
      Result := Result + Four_Bytes (Byte2) * 2 ** 16;
      Result := Result + Four_Bytes (Byte1) * 2 ** 24;

      return Result;
   end Bytes_To_Four_Bytes;

   function Four_Bytes_To_Bytes (Bytes : Four_Bytes)
      return Four_Byte_Array is
      Result : Four_Byte_Array;
      Temp : Four_Bytes := Bytes;
   begin
      Result (3) := Extract_Byte (Temp);
      Temp := Temp / 2 ** 8;
      Result (2) := Extract_Byte (Temp);
      Temp := Temp / 2 ** 8;
      Result (1) := Extract_Byte (Temp);
      Temp := Temp / 2 ** 8;
      Result (0) := Extract_Byte (Temp);

      return Result;
   end Four_Bytes_To_Bytes;
end Bitwise;