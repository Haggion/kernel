with Lines; use Lines;

package IO is
   procedure Put_Char (Ch : Integer);
   pragma Import (C, Put_Char, "putchar");

   procedure Put_Char (Ch : Character);
   procedure Put_String (Str : String;
      End_With : Character := Character'Val (10));
   procedure Put_Line (Text : Line;
      End_With : Character := Character'Val (10));
   procedure Put_Int (Int : Long_Integer);
   pragma Export (C, Put_Int, "_put_int");

   procedure New_Line;

   function Get_Char return Character;
   function Get_Line (Show_Typing : Boolean) return Line;

private
   function Last_Pressed return Character;
   pragma Import (C, Last_Pressed, "getchar");
   --  Either returns 1 or 0: 1 if true, 0 if false
   function Data_Ready return Integer;
   pragma Import (C, Data_Ready, "dataready");

   procedure Put_C_String (Text : Line);
   pragma Export (C, Put_C_String, "_put_cstring");

   procedure Backspace;
end IO;