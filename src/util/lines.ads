--  Adds fixed with char arrays, similar to C strings.
--  Used in place of strings where the string has to change size at runtime
--  Null terminated (Character'Val (0))

package Lines is
   type Line_Index is range 1 .. 256;
   type Line is array (Line_Index) of Character;
   function "=" (Left, Right : Line) return Boolean;

   function Make_Line (Text : String) return Line;
   procedure Append_To_Line (Target : access Line; Suffix : Character);
   function Substring (
      Text : Line;
      Start_Index : Line_Index;
      End_Index : Line_Index := 256
   ) return Line;

   Null_Ch : constant Character := Character'Val (0);

   function Length (Text : Line) return Natural;
end Lines;