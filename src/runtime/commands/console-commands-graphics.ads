with Renderer; use Renderer;

package Console.Commands.Graphics is
   function Draw (Args : Arguments) return Return_Data;

   function Arg_To_Color (Arg : Atom) return Color_Type;
end Console.Commands.Graphics;