with Error_Handler; use Error_Handler;
with Lines;
with IO; use IO;
with Interfaces; use Interfaces;

package body CrOS_EC is
   function SPI_Transfer_Byte (Data : Byte) return Byte;
   pragma Import (C, SPI_Transfer_Byte, "transfer_pl022_spi");
   procedure Delay_Microseconds (Time : Long_Unsigned);
   pragma Import (C, Delay_Microseconds, "delay_us");
   procedure GPIO_High (Pin : Byte);
   pragma Import (C, GPIO_High, "starfive_pinctrl_high");
   procedure GPIO_Low (Pin : Byte);
   pragma Import (C, GPIO_Low, "starfive_pinctrl_low");
   procedure Apply_Pinmux;
   pragma Import (C, Apply_Pinmux, "starfive_pinmux_apply_spi1_0");
   procedure Cleanup_SPI;
   pragma Import (C, Cleanup_SPI, "cleanup_pl022_spi");

   Pin : constant Byte := 57;

   procedure Enable is
      procedure Enable_SPI;
      pragma Import (C, Enable_SPI, "enable_pl022_spi");
      procedure GPIO_Init (Pin_To_Init : Byte; State : Byte);
      pragma Import (C, GPIO_Init, "starfive_pinctrl_init_pin");
   begin
      Enable_SPI;
      Apply_Pinmux;
      GPIO_Init (Pin, 1);
   end Enable;

   function EC_Command (
      Command : Unsigned;
      Version : Short_Unsigned;
      Request : Byte_Array;
      Debug : Boolean
   ) return Byte_Array_Ptr is
      subtype Header is Byte_Array (0 .. 7);

      Request_Header : Header;
      Response_Header : Header;

      Response : Byte_Array_Ptr := new Byte_Array (1 .. 0);
   begin
      Cleanup_SPI;

      --  make request header
      Request_Header (0) := 3; --  for version 3
      Request_Header (1) := 0; --  checksum nonce placeholder
      --  put 16bit command as LE
      Request_Header (2) := Byte (Command mod (2 ** 8));
      Request_Header (3) := Byte (Command / (2 ** 8));
      Request_Header (4) := Byte (Version);
      Request_Header (5) := 0; --  reserved nonsense
      --  put 16bit request length as LE
      Request_Header (6) := Byte (Request'Length mod (2 ** 8));
      Request_Header (7) := Byte (Request'Length / (2 ** 8));

      --  compute request header checksum
      --  header checksum must be so that full checksum mod 256 = 0
      declare
         Checksum : Long_Unsigned := 0;
      begin
         for Data_Byte of Request_Header loop
            Checksum := Checksum + Long_Unsigned (Data_Byte);
         end loop;

         for Data_Byte of Request loop
            Checksum := Checksum + Long_Unsigned (Data_Byte);
         end loop;

         --  set checksum
         Request_Header (1) := Byte ((-Checksum) mod 256);
      end;

      GPIO_Low (Pin);

      if Debug then
         Put_String ("[EC CMD] Enabling GPIO pin");
      end if;

      Delay_Microseconds (50);

      if Debug then
         Put_String ("[EC CMD] Sending request");
      end if;

      --  send cmd
      SPI_Write (Byte_Array (Request_Header));
      SPI_Write (Request);

      Delay_Microseconds (200);

      if Debug then
         Put_String ("[EC CMD] Waiting for frame");
      end if;

      --  wait for the response (indicated by 0xEC)
      if not Can_Find_Frame_Start then
         GPIO_High (Pin);
         Error_Handler.Throw ((
            Error_Handler.CrOS_EC_Error,
            Lines.Make_Line (
               "Timed out"
            ),
            Lines.Make_Line (
               "CrOS_EC Driver"
            ),
            0,
            No_Extra,
            Driver
         ));
         return Response;
      end if;

      --  read response
      Response_Header := Header (SPI_Read (Response_Header'Length).all);

      --  make sure it's the right version
      if Response_Header (0) /= 3 then
         GPIO_High (Pin);
         Error_Handler.Throw ((
            Error_Handler.CrOS_EC_Error,
            Lines.Make_Line (
               "Expected protocol V3"
            ),
            Lines.Make_Line (
               "CrOS_EC Driver"
            ),
            0,
            No_Extra,
            Driver
         ));
         return Response;
      end if;

      --  make sure the command was successful
      declare
         Result : Short_Unsigned;
      begin
         Result := Short_Unsigned (Response_Header (3));
         Result := Result * 256;
         Result := Result + Short_Unsigned (Response_Header (2));

         if Result /= 0 then
            GPIO_High (Pin);
            Error_Handler.Throw ((
               Error_Handler.CrOS_EC_Error,
               Lines.Make_Line (
                  "Response contained error: "
               ),
               Lines.Make_Line (
                  "CrOS_EC Driver"
               ),
               0,
               No_Extra,
               Driver
            ));
            return Response;
         end if;
      end;

      --  parse the response length & read response
      declare
         Response_Length : Short_Unsigned;
      begin
         Response_Length := Short_Unsigned (Response_Header (5));
         Response_Length := Response_Length * 256;
         Response_Length :=
            Response_Length +
            Short_Unsigned (Response_Header (4));

         Response := SPI_Read (Natural (Response_Length));
      end;

      --  verify the checksum is mod 256 = 0
      declare
         Sum : Long_Unsigned := 0;
      begin
         for Byte_Data of Response_Header loop
            Sum := Sum + Long_Unsigned (Byte_Data);
         end loop;

         for Byte_Data of Response.all loop
            Sum := Sum + Long_Unsigned (Byte_Data);
         end loop;

         if Sum mod 256 /= 0 then
            GPIO_High (Pin);
            Error_Handler.Throw ((
               Error_Handler.CrOS_EC_Error,
               Lines.Make_Line (
                  "Invalid checksum"
               ),
               Lines.Make_Line (
                  "CrOS_EC Driver"
               ),
               0,
               No_Extra,
               Driver
            ));
            return Response;
         end if;
      end;

      GPIO_High (Pin);

      return Response;
   end EC_Command;

   procedure SPI_Write (Bytes : Byte_Array) is
      Discard : Byte;
      pragma Unreferenced (Discard);
   begin
      if Bytes'Length > 0 then
         for Data_Byte of Bytes loop
            Discard := SPI_Transfer_Byte (Data_Byte);
         end loop;
      end if;
   end SPI_Write;

   function SPI_Read (Length : Natural) return Byte_Array_Ptr is
      Read : constant Byte_Array_Ptr := new Byte_Array (0 .. Length - 1);
   begin
      for I in Read'Range loop
         Read (I) := SPI_Transfer_Byte (0);
      end loop;

      return Read;
   end SPI_Read;

   --  we are searching for this (cleverly named) byte
   Frame_Start : constant Byte := 16#EC#;
   function Can_Find_Frame_Start return Boolean is
      --  we gotta call it quits eventually
      Max_Polls : constant Natural := 2000;
      T : Byte;
   begin
      for K in 1 .. Max_Polls loop
         T := SPI_Transfer_Byte (0);

         Put_Int (Long_Integer (T));
         Put_Char (' ');

         if T = Frame_Start then
            return True;
         end if;
      end loop;

      return False;
   end Can_Find_Frame_Start;
end CrOS_EC;