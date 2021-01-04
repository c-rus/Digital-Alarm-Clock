----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 09:43:37 PM
-- Module Name: SyncCounter - arch
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SyncCounter is
    port(
        CLK, RESET_L : IN std_logic;
        COUNT : OUT std_logic_vector(2 downto 0)
    );
end entity;

architecture arch of SyncCounter is
    
    signal counter : std_logic_vector(2 downto 0) := "000";
begin
    COUNT <= counter;
    --3-bit asynchronous counter 0, 1, 2, 3, 4, 0...
    COUNT_P : process(CLK, RESET_L)
    begin
        if(RESET_L = '0') then
            counter <= "000";         
        elsif(rising_edge(CLK)) then
            if(counter = "000") then
                counter <= "001";
            elsif(counter = "001") then
                counter <= "010";
            elsif(counter = "010") then
                counter <= "011";
            elsif(counter = "011") then
                counter <= "100";
			else
				counter <= "000";
            end if;
        end if;
    end process;

end architecture;