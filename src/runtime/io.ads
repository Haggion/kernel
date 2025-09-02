with Lines; use Lines;
with System;
with Lines.List; use Lines.List;
with System.Unsigned_Types; use System.Unsigned_Types;

package IO is
   ESC : constant Character := Character'Val (27);
   LF : constant Character := Character'Val (10);
   CR : constant Character := Character'Val (13);
   NUL : constant Character := Character'Val (0);
   ENDL : constant String := LF & CR;

   type Channel is (
      UART, Term, Debug, Default
   );

   type Stream is record
      Input : Channel;
      Output : Channel;
   end record;

   UART_Stream : constant Stream := (UART, UART);
   Default_Stream : constant Stream := (Default, Default);
   Main_Stream : Stream := UART_Stream;

   procedure UART_Put_Char (Ch : Integer);
   pragma Import (C, UART_Put_Char, "uart_put_char");

   procedure Put_Char (
      Ch : Integer;
      S : Stream := Default_Stream
   );
   procedure Put_Char (
      Ch : Character;
      S : Stream := Default_Stream
   );
   procedure Put_String (
      Str : String;
      End_With : Character := Character'Val (10);
      S : Stream := Default_Stream
   );
   procedure Put_Line (
      Text : Line;
      End_With : Character := Character'Val (10);
      S : Stream := Default_Stream
   );
   procedure Put_Int (
      Int : Long_Integer;
      S : Stream := Default_Stream
   );

   procedure Put_Address (
      Address : System.Address;
      S : Stream := Default_Stream
   );

   procedure New_Line (S : Stream := Default_Stream);

   function Get_Char (S : Stream := Default_Stream) return Character;
   function Get_Line (
      Show_Typing : Boolean;
      S : Stream := Default_Stream
   ) return Line;
   function Get_List (
      Show_Typing : Boolean;
      S : Stream := Default_Stream
   ) return Ch_List_Ptr;

   procedure Put_Hex (Number : Long_Long_Unsigned);
   pragma Export (C, Put_Hex, "_put_hex");
private
   function UART_Get_Char return Character;
   pragma Import (C, UART_Get_Char, "uart_get_char");

   procedure Put_C_String (Text : Line);
   pragma Export (C, Put_C_String, "_put_cstring");

   --  since we're moving to graphics, and by default
   --  machines with graphics support stop using UART
   --  for _put_cstring, it's useful to have UART explicit
   --  versions around, allowing for debugging before
   --  graphics are initialized (or for when graphics
   --  are what need to be debugged :P)
   procedure UART_Put_C_String (Text : Line);
   pragma Export (C, UART_Put_C_String, "_uart_put_cstring");

   procedure Put_C_Int (Int : Long_Integer);
   pragma Export (C, Put_C_Int, "_put_int");

   procedure UART_Put_C_Int (Int : Long_Integer);
   pragma Export (C, UART_Put_C_Int, "_uart_put_int");

   procedure Backspace (S : Stream := Default_Stream);
   function Is_Backspace (Ch : Character) return Boolean;
end IO;