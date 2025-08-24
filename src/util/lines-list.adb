with Error_Handler; use Error_Handler;

package body Lines.List is
   function Make_Str (List : Ch_List_Ptr) return Str_Ptr is
      Str_Builder : constant Str_Ptr := new Str (1 .. List.Length);
      Temp : Char_List_Node_Ptr := List.First;
      Index : Natural := Str_Builder'First;
   begin
      while Temp.Value /= Null_Ch loop
         Str_Builder (Index) := Temp.Value;

         exit when Temp.Next = null;
         Index := Index + 1;
         Temp := Temp.Next;
      end loop;

      return Str_Builder;
   end Make_Str;

   procedure Append (
      List : in out Ch_List_Ptr;
      Value : Character
   ) is
      New_Node : constant CLNP := new Char_List_Node;
   begin
      if List = null then
         List := new Char_List;
      end if;

      if List.First = null then
         List.First := New_Node;
      end if;

      if List.Last /= null then
         List.Last.Next := New_Node;
      end if;

      New_Node.Value := Value;
      New_Node.Last := List.Last;

      List.Last := New_Node;
      List.Length := List.Length + 1;
   end Append;

   procedure Shave (List : Ch_List_Ptr) is
      New_Last : constant CLNP := List.Last.Last;
   begin
      if List.Last /= null then
         Free (List.Last);
         List.Last := New_Last;

         if New_Last /= null then
            New_Last.Next := null;
         end if;

         List.Length := List.Length - 1;
      else
         Throw ((
            Index_Error,
            Make_Line ("Tried to shave element off an empty list"),
            Make_Line ("lines-list.shave"),
            0,
            No_Extra,
            User
         ));
      end if;
   end Shave;

   function Empty (List : Ch_List_Ptr) return Boolean is
   begin
      if List = null then
         return True;
      end if;

      return List.Length = 0;
   end Empty;
end Lines.List;