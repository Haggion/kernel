--  Adds doubly linked lists for characters,
--  allowing efficient storage of strings with
--  often resizing (e.g. input)

package Lines.List is
   type Char_List_Node;
   type Char_List_Node_Ptr is access Char_List_Node;
   type Char_List_Node is record
      Value : Character := Null_Ch;
      Next : Char_List_Node_Ptr := null;
      Last : Char_List_Node_Ptr := null;
   end record;
   subtype CLNP is Char_List_Node_Ptr;

   type Char_List is record
      First : Char_List_Node_Ptr := null;
      Last : Char_List_Node_Ptr := null;
      Length : Natural := 0;
   end record;
   type Ch_List_Ptr is access Char_List;

   function Make_Str (List : Ch_List_Ptr) return Str_Ptr;

   --  adds a new element to a list at the end
   procedure Append (
      List : in out Ch_List_Ptr;
      Value : Character
   );

   --  removes the last element in a list
   procedure Shave (List : Ch_List_Ptr);

   procedure Free is new Ada.Unchecked_Deallocation
   (
      Char_List_Node,
      Char_List_Node_Ptr
   );

   function Empty (List : Ch_List_Ptr) return Boolean;

   procedure Free (List : in out Ch_List_Ptr);

private
   --  This shouldn't be used for freeing whole lists as
   --  it doesn't delete the nodes. Use Free instead for
   --  that.
   procedure Free_Header is new Ada.Unchecked_Deallocation
   (
      Char_List,
      Ch_List_Ptr
   );
end Lines.List;