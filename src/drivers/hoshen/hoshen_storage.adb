with Driver_Handler;

--  Command IDs:
--  Save/send block - 0x0
--  Request block   - 0x1

package body Hoshen_Storage is
   function Request_Block (Address : Unsigned) return Block_Bytes is
      Block : Block_Bytes;
      Addr_Bytes : constant Byte_Array_Ptr := Split_Into_Bytes (Address);
   begin
      --  say we're issuing a request block command
      Driver_Handler.UART_Put_Char (16#EE#);
      Driver_Handler.UART_Put_Char (16#01#);

      --  say how long the address is
      Driver_Handler.UART_Put_Char (Addr_Bytes'Length);
      --  send over the address
      for I in Addr_Bytes'Range loop
         Driver_Handler.UART_Put_Char (Integer (Addr_Bytes (I)));
      end loop;

      --  read block
      for I in Block'Range loop
         Block (I) := Byte (Character'Pos (Driver_Handler.UART_Get_Char));
      end loop;

      return Block;
   end Request_Block;

   procedure Send_Block (Address : Unsigned; Data : Block_Bytes) is
      Addr_Bytes : constant Byte_Array_Ptr := Split_Into_Bytes (Address);
   begin
      --  say we're issuing a send block command
      Driver_Handler.UART_Put_Char (16#EE#);
      Driver_Handler.UART_Put_Char (16#00#);

      --  say how long the address is
      Driver_Handler.UART_Put_Char (Addr_Bytes'Length);
      --  send over the address
      for I in Addr_Bytes'Range loop
         Driver_Handler.UART_Put_Char (Integer (Addr_Bytes (I)));
      end loop;

      --  send block
      for I in Data'Range loop
         Driver_Handler.UART_Put_Char (Integer (Data (I)));
      end loop;
   end Send_Block;

   procedure Wait_Until_Active is
      Dummy : Character;
      pragma Unreferenced (Dummy);
   begin
      Driver_Handler.UART_Put_Char (16#EF#);

      Dummy := Driver_Handler.UART_Get_Char;
   end Wait_Until_Active;

   function Split_Into_Bytes (Number : Unsigned) return Byte_Array_Ptr is
      Num_Bytes_Needed : Unsigned := 0;
      Split : Byte_Array_Ptr;
   begin
      if Number = 0 then
         Split := new Byte_Array (0 .. 0);
         Split (0) := 0;

         return Split;
      end if;

      declare
         Temp : Unsigned := Number;
      begin
         while Temp > 0 loop
            Temp := Temp / 256;
            Num_Bytes_Needed := Num_Bytes_Needed + 1;
         end loop;
      end;

      Split := new Byte_Array (0 .. Integer (Num_Bytes_Needed - 1));

      declare
         Temp : Unsigned := Number;
         I : Integer := 0;
      begin
         while Temp > 0 loop
            Split (I) := Byte (Temp mod 256);
            Temp := Temp / 256;
            I := I + 1;
         end loop;
      end;

      return Split;
   end Split_Into_Bytes;
end Hoshen_Storage;