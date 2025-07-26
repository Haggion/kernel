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
         Put_Char (Ch);
      end loop;

      Put_Char (End_With);
   end Put_String;

   procedure Put_Line (Text : Line;
      End_With : Character := Character'Val (10)) is
   begin
      for Ch of Text loop
         exit when Ch = Character'Val (0);
         Put_Char (Ch);
      end loop;

      Put_Char (End_With);
   end Put_Line;

   procedure Put_Int (Int : Long_Integer) is
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

   function Get_Line (Show_Typing : Boolean) return Line is
      Input : Character;
      LineBuilder : Line := (others => Character'Val (0));
      Index : Line_Index := 1;
   begin
      Input := Get_Char;

      while Character'Pos (Input) /= 13 loop
         if Show_Typing then
            Put_Char (Input);
         end if;

         if Character'Pos (Input) = 127 then
            if Index > 1 then
               Index := Index - 1;
               LineBuilder (Index) := Character'Val (0);

               if Show_Typing then
                  Backspace;
               end if;
            end if;
         else
            LineBuilder (Index) := Input;
            Index := Index + 1;
         end if;

         Input := Get_Char;
      end loop;

      return LineBuilder;
   end Get_Line;

   procedure Backspace is
      Backspace_Char : constant Integer := 8;
   begin
      Put_Char (Backspace_Char);
      Put_Char (' ');
      Put_Char (Backspace_Char);
   end Backspace;

   procedure Put_C_String (Text : Line) is
   begin
      Put_Line (Text, Character'Val (0));
   end Put_C_String;
end IO;