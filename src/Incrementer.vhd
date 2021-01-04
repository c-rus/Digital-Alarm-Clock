----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date:
-- Module Name: Incrementer - arch
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Incrementer is
	port(
		C_IN : in std_logic;
		IN_NUMBER : in std_logic_vector(3 downto 0);
		OUT_NUMBER : out std_logic_vector(3 downto 0);
		C_OUT : out std_logic
	);
end entity;

architecture arch of Incrementer is
	signal sum : std_logic_vector(3 downto 0);
	signal carry : std_logic_vector(4 downto 0);
	
begin
	--simple adder that can only increase in value by 1 (C_IN + IN_NUMBER = C_OUT + OUT_NUMBER)
    carry(0) <= C_IN;
	
    ADDER : for i in 0 to 3 generate
        sum(i) <= IN_NUMBER(i) XOR carry(i);
        carry(i+1) <= IN_NUMBER(i) AND carry(i);
    end generate ADDER;

    OUT_NUMBER <= sum;
    C_OUT <= carry(4);

end architecture;