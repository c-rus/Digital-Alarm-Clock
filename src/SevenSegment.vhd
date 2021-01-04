----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 10:53:09 AM
-- Module Name: SevenSegment - Behavioral
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- |-0-|  |-A-|
-- 5   1  F   B
-- |-6-|  |-G-|
-- 4   2  E   C
-- |-3-|  |-D-|

entity SevenSegment is
    port( 
        NUMBER : in STD_LOGIC_VECTOR (3 downto 0);
        HEX : out STD_LOGIC_VECTOR (6 downto 0)
    );
end entity;

architecture arch of SevenSegment is

begin
    --hex is 0,1,2,3,4,5,6 (A,B,C,D,E,F,G)
    HEX <= "1111110" when (NUMBER = "0000") else
           "0110000" when (NUMBER = "0001") else
           "1101101" when (NUMBER = "0010") else
           "1111001" when (NUMBER = "0011") else
           "0110011" when (NUMBER = "0100") else
           "1011011" when (NUMBER = "0101") else
           "1011111" when (NUMBER = "0110") else
           "1110000" when (NUMBER = "0111") else
           "1111111" when (NUMBER = "1000") else
           "1110011" when (NUMBER = "1001") else
           "0000001";

end architecture;