--  Adds fixed with char arrays, similar to C strings.
--  Used in place of strings where the string has to change size at runtime
--  Null terminated (Character'Val (0))

with Ada.Unchecked_Deallocation;

package Lines is
   type Line_Index is range 1 .. 256;
   type Line is array (Line_Index) of Character;
   function "=" (Left, Right : Line) return Boolean;

   subtype Str is String;
   type Str_Ptr is access Str;
   Null_Ch : constant Character := Character'Val (0);
   Empty_Line : constant Line := (others => Null_Ch);
   Empty_Str : Str_Ptr := new Str'("");

   function "=" (Left : Str_Ptr; Right : String) return Boolean;

   function Make_Line (Text : String) return Line;
   function Make_Str (Text : Line) return Str_Ptr;

   procedure Append_To_Line (Target : access Line; Suffix : Character);
   procedure Append_To_Line (Appended : access Line; Appending : Line);
   procedure Append_New_Line (Target : access Line);

   function Substring (
      Text : Line;
      Start_Index : Line_Index;
      End_Index : Line_Index := 256
   ) return Line;
   function Substring (
      Text : Str_Ptr;
      Start_Index : Natural;
      End_Index : Natural := 0
   ) return Str_Ptr;
   function Str_Substring (
      Text : Line;
      Start_Index : Natural;
      End_Index : Natural := 0
   ) return Str_Ptr;

   function Length (Text : Line) return Natural;

   procedure Free is new
      Ada.Unchecked_Deallocation (Str, Str_Ptr);
end Lines;