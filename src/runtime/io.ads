with Lines; use Lines;
with System;

package IO is
   type Channel is (
      UART, Term
   );

   type Stream is record
      Input : Channel;
      Output : Channel;
   end record;

   UART_Stream : constant Stream := (UART, UART);
   Main_Stream : Stream := UART_Stream;

   procedure UART_Put_Char (Ch : Integer);
   pragma Import (C, UART_Put_Char, "uart_put_char");

   procedure Put_Char (
      Ch : Integer;
      S : Stream := UART_Stream
   );
   procedure Put_Char (
      Ch : Character;
      S : Stream := UART_Stream
   );
   procedure Put_String (
      Str : String;
      End_With : Character := Character'Val (10);
      S : Stream := UART_Stream
   );
   procedure Put_Line (
      Text : Line;
      End_With : Character := Character'Val (10);
      S : Stream := UART_Stream
   );
   procedure Put_Int (
      Int : Long_Integer;
      S : Stream := UART_Stream
   );

   procedure Put_Address (
      Address : System.Address;
      S : Stream := UART_Stream
   );

   procedure New_Line (S : Stream := UART_Stream);

   function Get_Char (S : Stream := UART_Stream) return Character;
   function Get_Line (
      Show_Typing : Boolean;
      S : Stream := UART_Stream
   ) return Line;

private
   function UART_Get_Char return Character;
   pragma Import (C, UART_Get_Char, "uart_get_char");

   procedure Put_C_String (Text : Line);
   pragma Export (C, Put_C_String, "_put_cstring");

   procedure Put_C_Int (Int : Long_Integer);
   pragma Export (C, Put_C_Int, "_put_int");

   procedure Backspace (S : Stream := UART_Stream);
end IO;