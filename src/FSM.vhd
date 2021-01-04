----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 07:55:27 PM
-- Module Name: FSM - arch
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    port(
    CLK, RESET_L : IN std_logic;
    set_time_swt, set_alarm_swt, snooze, zero_seconds : IN std_logic;
    cur_time, alarm_time : IN std_logic_vector(15 downto 0);
    in_time, in_set_time, in_set_alarm, in_alarm : OUT std_logic
    );
end FSM;

architecture arch of FSM is
    type state is (S_TIME, S_ALARM, S_SET_ALARM, S_SET_TIME); --four different state for FSM
    
    signal cur_state : state := S_TIME;
    signal s_bus : std_logic_vector(3 downto 0); --used to output what state is currently active
    
begin
    
    in_time <= s_bus(3);
    in_set_time <= s_bus(2);
    in_set_alarm <= s_bus(1);
    in_alarm <= s_bus(0);

    FSM : process(CLK, RESET_L, cur_state, set_time_swt, set_alarm_swt, snooze, cur_time, alarm_time, zero_seconds)
    begin
    
        if(RESET_L = '0' or (snooze = '1' and cur_state = S_ALARM)) then --asynchronous behavior when bypassing alarm
            cur_state <= S_TIME;
            s_bus <= "1000";
        elsif(rising_edge(CLK)) then
            case cur_state is
                when (S_TIME) =>
                    if(cur_time = alarm_time and zero_seconds = '1') then --can only trigger alarm when is exactly the time (with 0 seconds)
                        cur_state <= S_ALARM;
                        s_bus <= "0001";
                    elsif(set_time_swt = '1') then
                        cur_state <= S_SET_TIME;
                        s_bus <= "0100";
                    elsif(set_alarm_swt = '1') then
                        cur_state <= S_SET_ALARM;
                        s_bus <= "0010";
                    end if;
            
                when (S_SET_ALARM) =>
                    --must return to in_time state
                    if(set_alarm_swt = '0') then
                        cur_state <= S_TIME;
                        s_bus <= "1000";
                    end if;
                    
                when (S_SET_TIME) =>
                    --must return to in_time state
                    if(set_time_swt = '0') then
                        cur_state <= S_TIME;
                        s_bus <= "1000";
                    end if;
                    
                when others => NULL;
                
            end case;
            
        end if;
    
    end process;

end architecture;