--  This package contains type definitions for
--  procedure accesses.
--  Used frequently by the driver handler
--  Types are named with the prefix CA_, followed
--  by the first letter of each type it has for its
--  parameters. If a type has an adjective (e.g. Long)
--  added to it, the first letter of the adjective is
--  added after the type's letter in lowercase.
--  For functions, after the parameters are specified,
--  an underscore followed by the letter of the return type
--  is used to specify.
--  If a type has a return value and no parameters, the name
--  should be specified CA_0_Returnletters
--  The names of parameters should follow their name inside the
--  procedure name, followed by a number which increments for
--  each parameter of the same type.

with System.Unsigned_Types; use System.Unsigned_Types;

package Callables is
   type CA_UII is access procedure (
      U0 : Unsigned;
      I0 : Integer;
      I1 : Integer
   );

   type CA_III is access procedure (
      I0 : Integer;
      I1 : Integer;
      I2 : Integer
   );

   type CA_IIII is access procedure (
      I0 : Integer;
      I1 : Integer;
      I2 : Integer;
      I3 : Integer
   );

   type CA_IIUll is access procedure (
      I0   : Integer;
      I1   : Integer;
      Ull0 : Long_Long_Unsigned
   );

   type CA_0_I is access function return Integer;
end Callables;