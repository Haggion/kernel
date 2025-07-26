with Lines; use Lines;

package Console is
   procedure Read_Eval_Print_Loop;
   function Execute_Command (To_Execute : Line) return Line;
end Console;