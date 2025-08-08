with Bitwise; use Bitwise;

package Renderer.Text is
   procedure Draw_Character (
      Ch : Character;
      X : Integer;
      Y : Integer;
      Scale : Integer;
      Color : Color_Type;
      BG_Color : Color_Type
   );
private
   --  this could be more storage optimized, instead
   --  storing each 5x5 bitmap as a 32 bit integer,
   --  but this way it's far easier to visualize the bitmap
   type Bitmap_5x5 is array (0 .. 4) of Byte;
   function Ch_To_Bitmap (Ch : Character) return Bitmap_5x5;

   procedure Draw_Bitmap_5x5 (
      Bitmap : Bitmap_5x5;
      X : Integer;
      Y : Integer;
      Scale : Integer;
      Color : Color_Type;
      BG_Color : Color_Type
   );
end Renderer.Text;