---------------------------------------------------------------------------------- 
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 06:16:45 PM
-- Module Name: IncrementerBCD - arch
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IncrementerBCD is
    port(
        C_IN : IN std_logic;
        IN_VALUE : IN std_logic_vector(3 downto 0);
        OUT_BCD : OUT std_logic_vector(3 downto 0);
        C_OUT : OUT std_logic
    );
end entity;

architecture arch of IncrementerBCD is
        signal sum : std_logic_vector(3 downto 0);
        signal carry : std_logic_vector(4 downto 0);
begin
    --simple adder that can only increment by 1 but caps at a max value of 9 before overflowing (BCD format)
    carry(0) <= C_IN;
    
    ADDER : for i in 0 to 3 generate
        sum(i) <= IN_VALUE(i) XOR carry(i);
        carry(i+1) <= IN_VALUE(i) AND carry(i);
    end generate ADDER;

    OUT_BCD <= "0000" when (sum = "1010") else
                sum;
    C_OUT <= '1' when (sum = "1010") else
             '0';

end architecture;