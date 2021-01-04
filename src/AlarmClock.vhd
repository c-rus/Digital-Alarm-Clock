----------------------------------------------------------------------------------
-- Engineer: Chase Ruskin
-- 
-- Create Date: 12/14/2020 09:37:32 PM
-- Module Name: AlarmClock - arch
-- Project Name: Digital Alarm Clock
-- Target Devices: Intel MAX 10 FPGA- 10M08SAU169C8G
-- Description: Alarm clock system able to set the time, report the time, set an
--              alarm time, detect the alarm, and bypass the alarm.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AlarmClock is
    port(
        CLK, RESET_L : IN std_logic;
        SET_TIME_SWT, SET_ALARM_SWT, SNOOZE_SWT, INC_MIN, INC_HOUR : IN std_logic;
        SSG : OUT std_logic_vector(6 downto 0);
        H1, H0, M1, M0, DOTS : OUT std_logic;
        RINGER : OUT std_logic
    );
end AlarmClock;

architecture arch of AlarmClock is
    --module for incrementing time in correct format
    component TimeCounter is
        port(
            CLK, RESET_L : IN std_logic;
		    INC_M, INC_H, SETTER, COUNT_SEC : IN std_logic;
            CUR_TIME : IN std_logic_vector(15 downto 0);
			FRESH_MINUTE : OUT std_logic;
            NEXT_TIME : OUT std_logic_vector(15 downto 0)
        );    
    end component;
    --module for rapidly iterating through the segments of the display
    component SyncCounter is
        port(
            CLK, RESET_L : IN std_logic;
            COUNT : OUT std_logic_vector(2 downto 0)
        );
    end component;
    --module for slowing down the internal CLK pin
    component ClockDivider is
        port(
            CLK : IN std_logic;
            period_t : IN std_logic_vector(23 downto 0);
            SLOW_CLK : OUT std_logic
        );
    end component;
    --module for converting a binary value into the correct seven segment signals
    component SevenSegment is
        port( 
            NUMBER : in STD_LOGIC_VECTOR (3 downto 0);
            HEX : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
	--module for state transitions within the system
	component FSM is
		port(
			CLK, RESET_L : IN std_logic;
			set_time_swt, set_alarm_swt, snooze, zero_seconds : IN std_logic;
			cur_time, alarm_time : IN std_logic_vector(15 downto 0);
			in_time, in_set_time, in_set_alarm, in_alarm : OUT std_logic
		);
	end component;

    signal time_clk, ssg_clk : std_logic;
    signal now_time, future_time, alarm_time, future_alarm_time, display_time : std_logic_vector(15 downto 0) := (others => '0');
    signal digit_index : std_logic_vector(2 downto 0);
    signal ssg_h1, ssg_h0, ssg_m1, ssg_m0 : std_logic_vector(6 downto 0);

	 --12MHz internal clk in targeted device
	 constant TIMING_CLK : std_logic_vector(23 downto 0) := "101101110001101100000000"; --12x10^6
	 constant DISPLAY_CLK : std_logic_vector(23 downto 0) := "000000000000010010110000"; --1200
	 
	 signal time_state, set_time_state, set_alarm_state, alarm_state : std_logic;
	 
	 signal new_minute : std_logic;
    
begin
    --output clock slowed to 1Hz to use for time counters
    uCDtime : ClockDivider port map(CLK=>CLK, 
                                    period_t=>TIMING_CLK, 
                                    SLOW_CLK=>time_clk);
    
    --output clock slowed to 1MHz to use for rapidly iterating through the multiple seven segment components
    uCDssg : ClockDivider port map(CLK=>CLK, 
                                   period_t=>DISPLAY_CLK, 
                                   SLOW_CLK=>ssg_clk);
    
    --counter to count through each seven segment component
    uSC : SyncCounter port map(CLK=>ssg_clk, 
                                RESET_L=>'1', 
                                COUNT=>digit_index);
    
    --wiring of the current time's counter
    uTC : TimeCounter port map(CLK=>time_clk, 
                               RESET_L=>RESET_L,
                               CUR_TIME=>now_time, 
                               NEXT_TIME=>future_time, 
                               COUNT_SEC=>'1', --wired to '1' so the current time can increment after 60 seconds has passed
                               INC_M=>INC_MIN, 
                               INC_H=>INC_HOUR, 
                               SETTER=>set_time_state, --can also be changed when setting the time
                               FRESH_MINUTE=>new_minute);
     
    --wiring of the alarm time's counter (used for when setting the alarm)                                    
    uATC : TimeCounter port map(CLK=>time_clk, 
                                RESET_L=>RESET_L, 
                                CUR_TIME=>alarm_time, 
                                NEXT_TIME=>future_alarm_time, 
                                COUNT_SEC=>'0', --wired to '0' so the alarm time can never increment as a normal time
                                INC_M=>INC_MIN, 
                                INC_H=>INC_HOUR, 
                                SETTER=>set_alarm_state, --can only be changed when setting the alarm time
                                FRESH_MINUTE=>OPEN);
     
    --wiring of the finite state machine that determines if to set alarm, set time, display the time, trigger the alarm, bypass the alarm                       
    uFSM : FSM port map(CLK=>CLK, 
                        RESET_L=>RESET_L, 
                        set_time_swt=>SET_TIME_SWT, 
                        set_alarm_swt=>SET_ALARM_SWT, 
                        snooze=>SNOOZE_SWT, 
                        cur_time=>now_time, 
                        zero_seconds=>new_minute, 
                        alarm_time=>alarm_time, 
                        in_time=>time_state, 
                        in_set_time=>set_time_state, 
                        in_set_alarm=>set_alarm_state, 
                        in_alarm=>alarm_state);
    --the four segments
    uSSG3 : SevenSegment port map(NUMBER=>display_time(15 downto 12), 
                                  HEX=>ssg_h1);
    uSSG2 : SevenSegment port map(NUMBER=>display_time(11 downto 8), 
                                  HEX=>ssg_h0);
    uSSG1 : SevenSegment port map(NUMBER=>display_time(7 downto 4), 
                                  HEX=>ssg_m1);
    uSSG0 : SevenSegment port map(NUMBER=>display_time(3 downto 0), 
                                  HEX=>ssg_m0);
    
    --determine which segment signals are being outputted                              
    SSG <= ssg_h1 when (digit_index = "000") else
           ssg_h0 when (digit_index = "001") else
           ssg_m1 when (digit_index = "010") else
           ssg_m0 when (digit_index = "011") else
		   "1100000" when (digit_index = "100"); --the two dots seperating hours and minutes needs its own time
    
    --determine which segment has the okay to be outputted indicated by a '0' and the rest are pulled high to '1'
    H1 <= '0' when (digit_index = "000") else
          '1';
    H0 <= '0' when (digit_index = "001") else
          '1';
    M1 <= '0' when (digit_index = "010") else
          '1';
    M0 <= '0' when (digit_index = "011") else
          '1';		
	DOTS <= '0' when (digit_index = "100") else
		    '1';
    --trigger the LED ON when the time has reached the alarm        
    RINGER <= '1' when (alarm_state = '1') else
			  '0';
					
	display_time <= alarm_time when (set_alarm_state = '1') else
					now_time;
						 
	now_time <= (others=>'0') when (RESET_L = '0') else
				future_time;
	
	alarm_time <= (others=>'0') when (RESET_L = '0') else
				  future_alarm_time when (set_alarm_state = '1');
					
end architecture;
