with System.Unsigned_Types; use System.Unsigned_Types;
with Bitwise; use Bitwise;

package CrOS_EC is
   procedure Enable;
   pragma Export (C, Enable, "cros_ec_enable");

   function EC_Command (
      Command : Unsigned;
      Version : Short_Unsigned;
      Request : Byte_Array;
      Debug : Boolean --  when enabled, output debug information
   ) return Byte_Array_Ptr;

private
   procedure SPI_Write (Bytes : Byte_Array);
   function SPI_Read (Length : Natural) return Byte_Array_Ptr;
   function Can_Find_Frame_Start return Boolean;
end CrOS_EC;