with Lines.Converter;
with Ada.Unchecked_Conversion;

package body IO is
   procedure Put_Char (
      Ch : Character;
      S : Stream := UART_Stream
   ) is
   begin
      Put_Char (Character'Pos (Ch), S);
   end Put_Char;

   procedure Put_Char (
      Ch : Integer;
      S : Stream := UART_Stream
   ) is
   begin
      case S.Output is
         when UART =>
            UART_Put_Char (Ch);
      end case;
   end Put_Char;

   procedure Put_String (
      Str : String;
      End_With : Character := Character'Val (10);
      S : Stream := UART_Stream
   ) is
   begin
      for Ch of Str loop
         Put_Char (Ch, S);
      end loop;

      if End_With = Character'Val (10) then
         New_Line (S);
      else
         Put_Char (End_With, S);
      end if;
   end Put_String;

   procedure Put_Line (
      Text : Line;
      End_With : Character := Character'Val (10);
      S : Stream := UART_Stream
   ) is
   begin
      for Ch of Text loop
         exit when Ch = Character'Val (0);
         Put_Char (Ch, S);
      end loop;

      if End_With = Character'Val (10) then
         New_Line (S);
      else
         Put_Char (End_With, S);
      end if;
   end Put_Line;

   procedure Put_Int (
      Int : Long_Integer;
      S : Stream := UART_Stream
   ) is
   begin
      Put_Line (
         Lines.Converter.Long_Int_To_Line (Int),
         Character'Val (0),
         S
      );
   end Put_Int;

   procedure Put_C_Int (Int : Long_Integer) is
   begin
      Put_Int (Int);
   end Put_C_Int;

   procedure New_Line (S : Stream := UART_Stream) is
   begin
      --  carriage return (\r)
      Put_Char (13, S);
      --  line feed (\n)
      Put_Char (10, S);
   end New_Line;

   function Get_Char (S : Stream := UART_Stream) return Character is
   begin
      case S.Input is
         when UART =>
            return UART_Get_Char;
      end case;
   end Get_Char;

   function Get_Line (
      Show_Typing : Boolean;
      S : Stream := UART_Stream
   ) return Line is
      Input : Character;
      LineBuilder : Line := (others => Character'Val (0));
      Index : Line_Index := 1;
   begin
      Input := Get_Char (S);

      while Character'Pos (Input) /= 13 loop
         if Show_Typing then
            Put_Char (Input, S);
         end if;

         if Character'Pos (Input) = 127 then
            if Index > 1 then
               Index := Index - 1;
               LineBuilder (Index) := Character'Val (0);

               if Show_Typing then
                  Backspace (S);
               end if;
            end if;
         else
            LineBuilder (Index) := Input;
            Index := Index + 1;
         end if;

         Input := Get_Char (S);
      end loop;

      return LineBuilder;
   end Get_Line;

   procedure Backspace (S : Stream := UART_Stream) is
      Backspace_Char : constant Integer := 8;
   begin
      Put_Char (Backspace_Char, S);
      Put_Char (' ', S);
      Put_Char (Backspace_Char, S);
   end Backspace;

   procedure Put_C_String (Text : Line) is
   begin
      Put_Line (Text, Character'Val (0));
   end Put_C_String;

   procedure Put_Address (
      Address : System.Address;
      S : Stream := UART_Stream
   ) is
      function Adr_To_Int is new
         Ada.Unchecked_Conversion (System.Address, Long_Integer);
   begin
      Put_Int (Adr_To_Int (Address), S);
   end Put_Address;
end IO;