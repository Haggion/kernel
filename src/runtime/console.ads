with Lines;

package Console is
   procedure Read_Eval_Print_Loop;
   function Execute_Command (To_Execute : Lines.Line) return Lines.Line;
end Console;