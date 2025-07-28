with File_System.Formatter;
with IO; use IO;

package body File_System.RAM_Disk is
   procedure Initialize is
   begin
      File_System.Formatter.Format (Storage'Access);
   end Initialize;

   procedure Print_Disk is
   begin
      for Block of Storage loop
         Put_Char ('[');
         for Data of Block loop
            Put_Int (Long_Integer (Data));
            Put_Char (' ');
         end loop;
         Put_Char (']');
         New_Line;
      end loop;
   end Print_Disk;
end File_System.RAM_Disk;