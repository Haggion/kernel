--  The driver handler package exposes abstract interfaces to drivers,
--  allowing the rest of the code to be unconcerned with choosing an
--  implementation.
package Driver_Handler is
   type UART_Implementations is (
      QEMU, StarFive, None
   );
   type Power_Implementations is (
      OpenSBI, None
   );
   type RTC_Implementations is (
      StarFive, None
   );

   procedure Init;
   pragma Export (C, Init, "_initialize_drivers");

   --  UART drivers
   procedure UART_Put_Char (Ch : Integer);
   pragma Export (C, UART_Put_Char, "uart_put_char");
   function UART_Get_Char return Character;
   pragma Export (C, UART_Get_Char, "uart_get_char");

   --  power drivers
   procedure Shutdown;
   pragma Export (C, Shutdown, "shutdown");
   procedure Reboot;
   pragma Export (C, Reboot, "reboot");

   --  RTC drivers
   function RTC_Seconds return Integer;
   pragma Export (C, RTC_Seconds, "rtc_seconds");
   function RTC_Minutes return Integer;
   pragma Export (C, RTC_Minutes, "rtc_minutes");
   function RTC_Hours return Integer;
   pragma Export (C, RTC_Hours, "rtc_hours");
   function RTC_Day return Integer;
   pragma Export (C, RTC_Day, "rtc_day");
   function RTC_Month return Integer;
   pragma Export (C, RTC_Month, "rtc_month");
   function RTC_Year return Integer;
   pragma Export (C, RTC_Year, "rtc_year");
   procedure Enable_RTC;
   pragma Export (C, Enable_RTC, "enable_rtc");
private
   --  UART drivers
   procedure QEMU_UART_Put_Char (Ch : Integer);
   pragma Import (C, QEMU_UART_Put_Char, "qemu_uart_put_char");
   function QEMU_UART_Get_Char return Character;
   pragma Import (C, QEMU_UART_Get_Char, "qemu_uart_get_char");

   procedure StarFive_UART_Put_Char (Ch : Integer);
   pragma Import (C, StarFive_UART_Put_Char, "starfive_uart_put_char");
   function StarFive_UART_Get_Char return Character;
   pragma Import (C, StarFive_UART_Get_Char, "starfive_uart_get_char");

   --  power drivers
   procedure OpenSBI_Shutdown;
   pragma Import (C, OpenSBI_Shutdown, "opensbi_shutdown");
   procedure OpenSBI_Reboot;
   pragma Import (C, OpenSBI_Reboot, "opensbi_reboot");

   --  RTC drivers
   function StarFive_RTC_Seconds return Integer;
   pragma Import (C, StarFive_RTC_Seconds, "starfive_rtc_seconds");
   function StarFive_RTC_Minutes return Integer;
   pragma Import (C, StarFive_RTC_Minutes, "starfive_rtc_minutes");
   function StarFive_RTC_Hours return Integer;
   pragma Import (C, StarFive_RTC_Hours, "starfive_rtc_hours");
   function StarFive_RTC_Day return Integer;
   pragma Import (C, StarFive_RTC_Day, "starfive_rtc_day");
   function StarFive_RTC_Month return Integer;
   pragma Import (C, StarFive_RTC_Month, "starfive_rtc_month");
   function StarFive_RTC_Year return Integer;
   pragma Import (C, StarFive_RTC_Year, "starfive_rtc_year");
   procedure StarFive_Enable_RTC;
   pragma Import (C, StarFive_Enable_RTC, "starfive_enable_rtc");
end Driver_Handler;