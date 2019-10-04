library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Traffic is
    Port ( Asynchronous_Reset      : in   STD_LOGIC;
           Clock      : in   STD_LOGIC;
           
           -- for debugging purposes
           debugLED   : out  std_logic;
			  LEDs       : out  std_logic_vector(2 downto 0);

           -- Car and pedestrian buttons
           CarEW      : in   STD_LOGIC; -- The Car's weight,travelling in the East-West Direction
           CarNS      : in   STD_LOGIC; -- The Car's weight,travelling in the North-South Direction
           PedEW      : in   STD_LOGIC; -- Pedestrian's button, travelling in the East-West Direction
           PedNS      : in   STD_LOGIC; -- Pedestrian's button, travelling in the North-South Direction
           
           -- Lights of each direcion under consideration
           LightsEW   : out STD_LOGIC_VECTOR (1 downto 0); -- The East-West Lights
           LightsNS   : out STD_LOGIC_VECTOR (1 downto 0)  -- The North-South Lights
           
           );
end Traffic;

architecture Beh of Traffic is


-- declaring intermediatory signals
	signal Synced_Counter_Reset, Green_Time, Yellow_Time, PedWalk_Time, Synced_Car_NS, 
	       Synced_Car_EW, Synced_CarPed_NS, Synced_CarPed_EW :    std_logic;
begin 
	process(Asynchronous_Reset, Clock)
	begin
	if (Asynchronous_Reset = '1') then
	  Synced_Car_NS              <= '0';
	  Synced_Car_EW              <= '0';
	  Synced_CarPed_NS           <= '0';
	  Synced_CarPed_EW           <= '0';
	 elsif (rising_edge(Clock)) then
	  Synced_Car_NS              <= CarNS;
	  Synced_Car_EW              <= CarEW;
	  Synced_CarPed_NS           <= PedNS;
	  Synced_CarPed_EW           <= PedEW;
	 end if;
end process;


-- instantiating Counter Module 
Counter: 
	entity work.Counter
	Port Map (
		Asynchronous_Reset     => Asynchronous_Reset,
		Clock                  => Clock,
		Synced_Counter_Reset   => Synced_Counter_Reset,
		Green_Time             => Green_Time,
		Yellow_Time            => Yellow_Time,
		PedWalk_Time           => PedWalk_Time
	);
	
-- instantiating StateMachine Module 
StateMachine:
	entity work.StateMachine
	Port Map (
		Asynchronous_Reset     => Asynchronous_Reset,
		Clock                  => Clock,
		debugLED               => debugLED,
		CarNS                  => Synced_Car_NS,
		CarEW                  => Synced_Car_EW,
		PedNS                  => Synced_CarPed_NS,
		PedEW                  => Synced_CarPed_EW,
		LightsEW               => LightsEW,
		LightsNS               => LightsNS,
		Synced_Counter_Reset   => Synced_Counter_Reset,
		Green_Time             => Green_Time,
		Yellow_Time            => Yellow_Time,
		PedWalk_Time           => PedWalk_Time
		
	);

end architecture Beh;