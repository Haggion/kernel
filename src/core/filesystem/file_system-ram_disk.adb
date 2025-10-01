with File_System.Formatter;
with IO; use IO;
with System.Unsigned_Types; use System.Unsigned_Types;

package body File_System.RAM_Disk is
   procedure Initialize is
   begin
      File_System.Formatter.Format;
   end Initialize;

   procedure Print_Disk is
   begin
      for Block of Storage loop
         Put_Char ('[');
         for Data of Block loop
            Put_Hex (Long_Long_Unsigned (Data));
            Put_Char (' ');
         end loop;
         Put_Char (']');
         New_Line;
      end loop;
   end Print_Disk;
end File_System.RAM_Disk;