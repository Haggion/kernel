with Console;
with IO;

procedure Kernel is
   type Arr is array (1 .. 128) of Integer;
   type Arr_A is access Arr;
   Ptr : constant Arr_A := new Arr;
begin
   Ptr (1) := 42;
   IO.Put_Int (Ptr (1));
   IO.New_Line;

   Console.Read_Eval_Print_Loop;

   loop
      null;
   end loop;
end Kernel;