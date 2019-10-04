library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity StateMachine is
    Port ( Asynchronous_Reset      : in   std_logic;
           Clock                   : in   std_logic;
           
		   -- Times obtained/controlled by the counter module
           Green_Time              : in   std_logic;
           Yellow_Time             : in   std_logic;
			  PedWalk_Time            : in   std_logic;
		   
		   -- For testing initial program loading errors
		     debugLED                : out  std_logic;
		   
           -- Car and Pedestrian buttons
           CarEW                   : in   std_logic; -- Car on EW road
           CarNS                   : in   std_logic; -- Car on NS road
           PedEW                   : in   std_logic; -- Pedestrian moving EW (crossing NS road)
           PedNS                   : in   std_logic; -- Pedestrian moving NS (crossing EW road)
           
           -- Lights of each direcion under consideration
           LightsEW                : out  std_logic_vector (1 downto 0); -- controls EW lights
           LightsNS                : out  std_logic_vector (1 downto 0);  -- controls NS lights
		   
		   -- Resetting the counter
		   Synced_Counter_Reset    : out   std_logic
           );
end StateMachine;

architecture Beh of StateMachine is
	constant RED    : std_logic_vector(1 downto 0) := "00";
	constant YELLOW : std_logic_vector(1 downto 0) := "01";
	constant GREEN  : std_logic_vector(1 downto 0) := "10";
	constant WALK   : std_logic_vector(1 downto 0) := "11";
	
	type StateType is (CarPed_NS, CarPed_EW, Car_NS, Car_EW, NStoEW, EWtoNS);
	signal PedMemory_NS, PedMemory_EW, PedReset_NS, PedReset_EW: std_logic;
	signal state, nextState: StateType;
	
begin
	debugLED <= Asynchronous_Reset; --sanity check
	
	process(Clock, Asynchronous_Reset) --sensitivity list
    begin
     if (Asynchronous_Reset = '1') then
	  state   <=   Car_EW;
	 elsif (rising_edge(Clock)) then
	  state   <=   nextState;
	 end if;
	end process;

	Synced_Counter_Reset <= '0';
	PedReset_NS <= '0';
	PedReset_EW <= '0';  --default values, prevents the synthesizing of unnecessary latches

process(state, CarEW, CarNS, PedMemory_EW, PedMemory_NS)  --process sensitivity list
begin
	Case (state) is
		when Car_NS => 
				nextState <= Car_NS;
				if (Green_Time = '0') then
				nextState <= Car_NS;	
				elsif (CarEW = '1' or PedMemory_EW = '1') then
				nextState <= NStoEW;
				Synced_Counter_Reset <= '1';  --counter is cleared
				elsif(PedMemory_NS = '1') then
				nextState <= CarPed_NS;  
				Synced_Counter_Reset <= '1'; 
				end if; 
				
				LightsNS <= GREEN; 
				LightsEW <= RED; 
				
				when Car_EW =>
					if (Green_Time = '0') then
						nextState <= Car_EW;
					elsif (CarNS = '1' or PedMemory_NS = '1') then
						nextState <= EWtoNS;
						Synced_Counter_Reset <= '1';
					elsif (PedMemory_EW = '1') then
						nextState <= CarPed_EW;
						Synced_Counter_Reset <= '1';
					end if;
						
					LightsNS <= RED; 
					LightsEW <= GREEN; 	
						
				when CarPed_NS =>
					nextState <= CarPed_NS;
					if (PedWalk_Time = '0') then
						nextState <= CarPed_NS;
					else 
						nextState <= Car_NS;
						Synced_Counter_Reset <= '1';
					end if;
					
					LightsNS <= WALK; 
					LightsEW <= RED;
					PedReset_NS <= '1';
					
				when CarPed_EW =>
					nextState <= CarPed_EW;
					if (PedWalk_Time = '0') then
						nextState <= CarPed_EW;
					else 
						nextState <= Car_EW;
						Synced_Counter_Reset <= '1';
					end if;
					
					LightsNS <= RED; 
					LightsEW <= WALK;
					PedReset_NS <= '1';
					
				when NStoEW =>
					nextState <= NStoEW;
					if (Yellow_Time = '0') then
						nextState <= NStoEW;
					elsif (PedMemory_EW = '1') then
						nextState <= CarPed_EW;
						Synced_Counter_Reset <= '1';
					else
						nextState <= Car_EW;
						Synced_Counter_Reset <= '1';
					end if;
					
					LightsNS <= YELLOW;
					LightsEW <= RED;
					
				when EWtoNS =>
					nextState <= EWtoNS;
					if (Yellow_Time = '0') then
						nextState <= EWtoNS;
					elsif (PedMemory_NS = '1') then
						nextState <= CarPed_NS;
						Synced_Counter_Reset <= '1';
					else
						nextState <= Car_NS;
						Synced_Counter_Reset <= '1';
					end if;
					
					LightsNS <= RED;
					LightsEW <= YELLOW;
					
	end Case;
						
end process;

-- The inputs on the pedetrian buttons are registered until cleared on the state
process (Clock, Asynchronous_Reset)
begin
	if (Asynchronous_Reset = '1') then
	  PedMemory_NS <= '0';
	  PedMemory_EW <= '0';
	elsif (rising_edge(Clock)) then
		  if (PedReset_NS = '1') then 
			PedMemory_NS <= '0';
		  elsif (PedNS = '1') then
			PedMemory_NS <= '1';
		  end if;
		  if (PedReset_EW = '1') then 
			PedMemory_EW <= '0';
		  elsif (PedEW = '1') then
			PedMemory_EW <= '1';
		  end if;
	end if;
end process;

end architecture Beh;