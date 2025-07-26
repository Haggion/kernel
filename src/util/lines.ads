--  Adds fixed with char arrays, similar to C strings.
--  Used in place of strings where the string has to change size at runtime
--  Null terminated (Character'Val (0))

package Lines is
   type Line is array (Natural range 1 .. 256) of Character;
   function "=" (Left, Right : Line) return Boolean;

   function Make_Line (Text : String) return Line;

   procedure Append_To_Line (Target : access Line; Suffix : Character);

   Null_Ch : constant Character := Character'Val (0);
end Lines;