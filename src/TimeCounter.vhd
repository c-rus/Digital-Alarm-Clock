----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 06:34:36 PM
-- Module Name: TimeCounter - Behavioral
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TimeCounter is
    port(
        CLK, RESET_L : IN std_logic;
		INC_M, INC_H, SETTER, COUNT_SEC : IN std_logic;
        CUR_TIME : IN std_logic_vector(15 downto 0);
		FRESH_MINUTE : OUT std_logic;
        NEXT_TIME : OUT std_logic_vector(15 downto 0)
    );    
end entity;

architecture arch of TimeCounter is

    component IncrementerBCD is
        port(
            C_IN : IN std_logic;
            IN_VALUE : IN std_logic_vector(3 downto 0);
            OUT_BCD : OUT std_logic_vector(3 downto 0);
            C_OUT : OUT std_logic
        );
    end component;
	 
	 component Incrementer is
		port(
			C_IN : in std_logic;
			IN_NUMBER : in std_logic_vector(3 downto 0);
			OUT_NUMBER : out std_logic_vector(3 downto 0);
			C_OUT : out std_logic
		);
	 end component;
    
    signal cur_min, cur_hour : std_logic_vector(7 downto 0);
    
    signal min_out, hour_out, new_min, new_hour : std_logic_vector(7 downto 0) := "00000000";
    signal min_carry, hour_carry, sec_carry : std_logic := '0';
	 
	signal cur_seconds, next_seconds : std_logic_vector(7 downto 0) := "00000000";
	constant MAX_SECONDS : std_logic_vector(7 downto 0) := "00111100"; --60 (BIN value)
	 
    
begin
						  
    cur_hour <= CUR_TIME(15 downto 8);
    cur_min <= CUR_TIME(7 downto 0);
	 
	 --seconds
	 uS0 : Incrementer port map(C_IN=>'1', IN_NUMBER=>cur_seconds(3 downto 0), OUT_NUMBER=>next_seconds(3 downto 0), C_OUT=>sec_carry);
	 uS1 : Incrementer port map(C_IN=>sec_carry, IN_NUMBER=>cur_seconds(7 downto 4), OUT_NUMBER=>next_seconds(7 downto 4), C_OUT=>OPEN);
    
    --minutes
    uM0 : IncrementerBCD port map(C_IN=>'1', IN_VALUE=>cur_min(3 downto 0), OUT_BCD=>min_out(3 downto 0), C_OUT=>min_carry);
    uM1 : IncrementerBCD port map(C_IN=>min_carry, IN_VALUE=>cur_min(7 downto 4), OUT_BCD=>min_out(7 downto 4), C_OUT=>OPEN);
    
    --hours
    uH0 : IncrementerBCD port map(C_IN=>'1', IN_VALUE=>cur_hour(3 downto 0), OUT_BCD=>hour_out(3 downto 0), C_OUT=>hour_carry);
    uH1 : IncrementerBCD port map(C_IN=>hour_carry, IN_VALUE=>cur_hour(7 downto 4), OUT_BCD=>hour_out(7 downto 4), C_OUT=>OPEN);
    
    COUNTER : process(CLK, RESET_L, min_out, hour_out, cur_hour, SETTER, cur_seconds, COUNT_SEC, next_seconds)
    begin
        if(RESET_L = '0') then --asynchronous reset
            new_min <= (others=>'0');
            new_hour <= (others=>'0');
			cur_seconds <= (others=>'0');
        elsif(rising_edge(CLK)) then
            
				if(SETTER = '0') then
					
					if(next_seconds = MAX_SECONDS) then
						cur_seconds <= (others=>'0');
						
						if(min_out = "01100000") then --reset at 60 minutes (BCD value)
							new_min <= "00000000";
	
							if(hour_out = "00100100") then --reset at 24 hours in (BCD value)
								new_hour <= "00000000";
							else
								new_hour <= hour_out;
							end if;
						else
							new_min <= min_out;
							new_hour <= cur_hour;
						end if;
						
					else
						if(COUNT_SEC = '1') then
							cur_seconds <= next_seconds;
						end if;
					end if;
			--if setter = '1' then the system will increment without waiting 60 seconds	
            elsif(SETTER = '1') then
					
					cur_seconds <= (others=>'0');
					--two seperate if statements because setting minutes and hours is not mutually exclusive
					if(INC_M = '1') then
						if(min_out = "01100000") then --reset at 60 minutes (BCD value)
							new_min <= "00000000";
						else
							new_min <= min_out;
						end if;
					else
						new_min <= cur_min;
					end if;
					
					if(INC_H = '1') then
						if(hour_out = "00100100") then --reset at 24 hours (BCD value)
							new_hour <= "00000000";
						else
							new_hour <= hour_out;
						end if;
					else
						new_hour <= cur_hour;
					end if;
					
				end if;
				
        end if;
    end process;
    
    NEXT_TIME <= new_hour & new_min;
	 
	FRESH_MINUTE <= '1' when (cur_seconds = "00000000") else
					'0';

end architecture;