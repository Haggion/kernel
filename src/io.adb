with Images;

package body IO is
   procedure Put_Char (Ch : Character) is
   begin
      Put_Char (Character'Pos (Ch));
   end Put_Char;

   procedure Put_String (Str : String;
      End_With : Character := Character'Val (10)) is
   begin
      for Ch of Str loop
         exit when Ch = Character'Val (0);
         Put_Char (Ch);
      end loop;

      Put_Char (End_With);
   end Put_String;

   procedure Put_Line (Line : Lines.Line;
      End_With : Character := Character'Val (10)) is
   begin
      for Ch of Line loop
         Put_Char (Ch);
      end loop;

      Put_Char (End_With);
   end Put_Line;

   procedure Put_Int (Int : Integer) is
   begin
      Put_Line (Images.Integer_Image (Int), Character'Val (0));
   end Put_Int;

   procedure New_Line is
   begin
      Put_Char (10);
   end New_Line;

   function Get_Char return Character is
   begin
      while Data_Ready = 0 loop
         null;
      end loop;

      return Last_Pressed;
   end Get_Char;

   function Get_Line (Show_Typing : Boolean) return Lines.Line is
      Input : Character;
      LineBuilder : Lines.Line := (others => Character'Val (0));
      Index : Natural := 1;
   begin
      Input := Get_Char;

      while Character'Pos (Input) /= 13 and Index <= 256 loop
         if Show_Typing then
            Put_Char (Input);
         end if;

         LineBuilder (Index) := Input;
         Input := Get_Char;

         Index := Index + 1;
      end loop;

      return LineBuilder;
   end Get_Line;
end IO;