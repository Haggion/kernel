with Renderer; use Renderer;
with Terminal;
with IO; use IO;
with Console.Commands.Graphics; use Console.Commands.Graphics;
with Error_Handler; use Error_Handler;

package body Console.Commands.Term is
   function Color (Args : Arguments) return Return_Data is
   begin
      if Args (0).Value /= Str then
         return Ret_Fail;
      elsif Args (1).Value = Void then
         return Ret_Fail;
      end if;

      declare
         Option : constant Str_Ptr := Args (0).Str_Val;
         Value : constant Color_Type := Arg_To_Color (Args (1));
      begin
         if Option = "font" then
            Terminal.Set_Font_Color (Value);
         elsif Option = "background" then
            Terminal.Set_Background_Color (Value);
         else
            Put_String ("Invalid option");
            return Ret_Fail;
         end if;
      end;

      return Ret_Void;
   end Color;

   function Clear (Args : Arguments) return Return_Data is
   begin
      if Args (0).Value = Void then
         --  ANSI ESC code for clearing the screen
         --  Thus it also clears UART terminal
         Put_String (ESC & "[2J");
         --  Also move cursor to start
         Put_String (ESC & "[1;1H");
         return Ret_Void;
      end if;

      --  if an argument is provided to the clear command,
      --  it ought to be a string specifying whether merely
      --  the terminal or if the console should be cleared
      --  (terminal => graphical; console => graphical & uart)
      if Args (0).Value /= Str then
         Throw ((
            Incorrect_Type,
            Make_Line ("Expected argument of clear to be string"),
            Make_Line ("Console.Commands.Term#Clear"),
            0,
            No_Extra,
            User
         ));
         return Ret_Fail;
      end if;

      if Args (0).Str_Val = "terminal" then
         Terminal.Clear;
      elsif Args (0).Str_Val = "console" then
         --  refer to start of function
         Put_String (ESC & "[2J");
         Put_String (ESC & "[1;1H");
      else
         Throw ((
            Invalid_Argument,
            Make_Line ("Expected argument to be either terminal or console"),
            Make_Line ("Console.Commands.Term#Clear"),
            0,
            No_Extra,
            User
         ));
         return Ret_Fail;
      end if;

      return Ret_Void;
   end Clear;
end Console.Commands.Term;