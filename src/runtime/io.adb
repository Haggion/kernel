with Lines.Converter;
with Ada.Unchecked_Conversion;
with Terminal;

package body IO is
   procedure Put_Char (
      Ch : Character;
      S : Stream := Default_Stream
   ) is
   begin
      Put_Char (Character'Pos (Ch), S);
   end Put_Char;

   procedure Put_Char (
      Ch : Integer;
      S : Stream := Default_Stream
   ) is
      Selected_Stream : Stream := S;
   begin
      if Selected_Stream.Output = Default then
         Selected_Stream := Main_Stream;
      end if;

      case Selected_Stream.Output is
         when UART =>
            UART_Put_Char (Ch);
         when Term =>
            Terminal.Put_Char (Character'Val (Ch));
         when Debug =>
            UART_Put_Char (Ch);
            Terminal.Put_Char (Character'Val (Ch));
         when Default =>
            --  shouldn't ever get here
            null;
      end case;
   end Put_Char;

   procedure Put_String (
      Str : String;
      End_With : Character := Character'Val (10);
      S : Stream := Default_Stream
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
      S : Stream := Default_Stream
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
      S : Stream := Default_Stream
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

   procedure UART_Put_C_Int (Int : Long_Integer) is
   begin
      Put_Int (Int, UART_Stream);
   end UART_Put_C_Int;

   procedure New_Line (S : Stream := Default_Stream) is
   begin
      --  carriage return (\r)
      Put_Char (13, S);
      --  line feed (\n)
      Put_Char (10, S);
   end New_Line;

   function Get_Char (S : Stream := Default_Stream) return Character is
      Selected_Stream : Stream := S;
   begin
      if Selected_Stream.Input = Default then
         Selected_Stream := Main_Stream;
      end if;

      case Selected_Stream.Input is
         when UART =>
            return UART_Get_Char;
         when Debug =>
            return UART_Get_Char;
         when Term =>
            return Character'Val (0);
         when Default =>
            return Character'Val (0);
      end case;
   end Get_Char;

   function Get_Line (
      Show_Typing : Boolean;
      S : Stream := Default_Stream
   ) return Line is
      Input : Character;
      LineBuilder : Line := (others => Character'Val (0));
      Index : Line_Index := 1;
   begin
      Input := Get_Char (S);

      while Character'Pos (Input) /= 13 loop
         if Is_Backspace (Input) then
            if Index > 1 then
               Index := Index - 1;
               LineBuilder (Index) := Character'Val (0);

               if Show_Typing then
                  Backspace (S);
               end if;
            end if;
         else
            if Show_Typing then
               Put_Char (Input, S);
            end if;

            LineBuilder (Index) := Input;
            Index := Index + 1;
         end if;

         Input := Get_Char (S);
      end loop;

      return LineBuilder;
   end Get_Line;

   function Get_List (
      Show_Typing : Boolean;
      S : Stream := Default_Stream
   ) return Ch_List_Ptr is
      List : Ch_List_Ptr := new Char_List;
      Input : Character;
   begin
      Input := Get_Char (S);

      while Character'Pos (Input) /= 13 loop
         if Is_Backspace (Input) then
            if List.Length >= 1 then
               Shave (List);

               if Show_Typing then
                  Backspace (S);
               end if;
            end if;
         else
            if Show_Typing then
               Put_Char (Input, S);
            end if;

            Append (List, Input);
         end if;

         Input := Get_Char (S);
      end loop;

      return List;
   end Get_List;

   function Is_Backspace (Ch : Character) return Boolean is
   begin
      case Character'Pos (Ch) is
         when 127 | 8 =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Backspace;

   procedure Backspace (S : Stream := Default_Stream) is
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

   procedure UART_Put_C_String (Text : Line) is
   begin
      Put_Line (Text, Character'Val (0), UART_Stream);
   end UART_Put_C_String;

   procedure Put_Address (
      Address : System.Address;
      S : Stream := Default_Stream
   ) is
      function Adr_To_Int is new
         Ada.Unchecked_Conversion (System.Address, Long_Integer);
   begin
      Put_Int (Adr_To_Int (Address), S);
   end Put_Address;

   procedure Put_Hex (
      Number : Long_Long_Unsigned;
      With_Prefix : Boolean := True
   ) is
   begin
      if With_Prefix then
         Put_String ("0x", Null_Ch);
      end if;

      Put_Line (
         Lines.Converter.Hex_To_Line (Number),
         End_With => Null_Ch
      );
   end Put_Hex;

   function Get_String (
      Show_Typing : Boolean := False;
      S : Stream := Default_Stream
   ) return Str_Ptr is
   begin
      return Make_Str (Get_List (
         Show_Typing,
         S
      ));
   end Get_String;
end IO;