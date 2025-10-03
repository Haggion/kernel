with Ada.Unchecked_Deallocation;

package Bitwise is
   type Four_Bytes is range 0 .. 2**32 - 1;
   type Byte is range 0 .. 2 ** 8 - 1
      with Size => 8;

   type Byte_Array is array (Natural range <>) of Byte
      with Component_Size => 8;
   type Byte_Array_Ptr is access Byte_Array;

   function Bytes_To_Four_Bytes (
      Byte1 : Byte;
      Byte2 : Byte;
      Byte3 : Byte;
      Byte4 : Byte
   ) return Four_Bytes;

   type Four_Byte_Array is array (0 .. 3) of Byte;
   function Four_Bytes_To_Bytes (
      Bytes : Four_Bytes
   ) return Four_Byte_Array;

   function Get_Bit (Num : Byte; Bit : Natural) return Boolean;
   function Set_Bit (Num : Byte; Bit : Natural; Value : Boolean) return Byte;

   function Extract_Byte (Num : Four_Bytes) return Byte;

   function "and"(Left : Byte; Right : Integer) return Byte;
   function "and"(Left : Four_Bytes; Right : Integer) return Byte;

   function "or"(Left : Byte; Right : Integer) return Byte;

   procedure Free is new
      Ada.Unchecked_Deallocation (Byte_Array, Byte_Array_Ptr);
end Bitwise;