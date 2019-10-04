library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Counter is
    Port ( Synced_Counter_Reset    : in  STD_LOGIC;
           Clock                   : in  STD_LOGIC;
           Asynchronous_Reset      : in  STD_LOGIC;
           Green_Time              : out  STD_LOGIC;
           Yellow_Time             : out  STD_LOGIC;
           PedWalk_Time            : out  STD_LOGIC);
end Counter;

architecture beh of Counter is
 -- declaring intermediatory signals to assign max values for each light time period/cycle
	signal Count : integer range 0 to 2000;
	constant GreenPedMax : integer := 400;  -- the amount of counts the pedestrian light will stay on
	constant GreenCarMax : integer := 800;  -- the amount of counts the NS/EW green lights for cars will stay on
	constant YellowMax : integer := 300;    -- the amount of counts the NS/EW Amber/Yellow lights for cars will stay on
	begin
		process(Clock, Asynchronous_Reset)
		begin
				
			if (Asynchronous_Reset = '1') then
				Count <= 0;
				Green_Time <= '0';
				Yellow_Time <= '0';
				PedWalk_Time <= '0';  -- global reset assignees
			elsif (rising_edge(Clock)) then
				if (Synced_Counter_Reset = '1') then
					Count <= 0;
					PedWalk_Time <= '0';
					Green_Time <= '0';
					Yellow_Time <= '0';
				else
					Count <= Count + 1;
					PedWalk_Time <= '0';
					Green_Time <= '0';
					Yellow_Time <= '0';
					-- if Count reaches GreenPedMax (400 counts) then assign a '1' to PedWalk_Time
					-- the specific amount of time it takes will depend on what frequency the clock has been tuned to
					if (Count = GreenPedMax) then 
						PedWalk_Time <= '1';
						Green_Time <= '0';
					Yellow_Time <= '0';
					end if;
					-- if Count reaches GreenCarMax (800 counts) then assign a '1' to Green_Time
					if (Count = GreenCarMax) then
						Green_Time <= '1';
						Yellow_Time <= '0';
						PedWalk_Time <= '0';
					end if;
					-- if count reaches YellowMax (300 counts) then assign a '1' to Yellow_Time
					if (Count = YellowMax) then
					Yellow_Time <= '1';
					PedWalk_Time <= '0';
					Green_Time <= '0';
					end if;
				end if;
			end if;	
	end process;
end beh;

