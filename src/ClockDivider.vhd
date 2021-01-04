----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 07:33:12 PM
-- Module Name: ClockDivider - arch
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockDivider is
    port(
        CLK : IN std_logic;
        period_t : IN std_logic_vector(23 downto 0); --value by how much will the clock be slowed down 
        SLOW_CLK : OUT std_logic
    );
end entity;

architecture arch of ClockDivider is
    
	component Incrementer is
		port(
			C_IN : in std_logic;
			IN_NUMBER : in std_logic_vector(3 downto 0);
			OUT_NUMBER : out std_logic_vector(3 downto 0);
			C_OUT : out std_logic
		);
	end component;

    signal next_reg, reg : std_logic_vector(23 downto 0) := (others=>'0');
    signal carry_bus : std_logic_vector(5 downto 0);
    
begin

    --wire Incrementer components together to create a larger incrementer used to slow down the internal CLK frequency
	uINC0 : Incrementer port map(C_IN=>'1', IN_NUMBER=>reg(3 downto 0), OUT_NUMBER=>next_reg(3 downto 0), C_OUT=>carry_bus(0));
    
	RIPPLE_ADDER : for i in 1 to 5 generate
		uX : Incrementer port map(C_IN=>carry_bus(i-1), IN_NUMBER=>reg((i*4)+3 downto (i*4)), OUT_NUMBER=>next_reg((i*4)+3 downto (i*4)), C_OUT=>carry_bus(i));
	end generate RIPPLE_ADDER;

    STRETCH : process(CLK)
    begin
        if(rising_edge(CLK)) then
            reg <= next_reg;
            
            if (reg = period_t) then
                reg <= (others=>'0');
                SLOW_CLK <= '1';
            else
                SLOW_CLK <= '0';
            end if;
        end if;
    
    end process;

end architecture;