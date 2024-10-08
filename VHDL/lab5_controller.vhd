--=============================================================================
--ENGS 31/ CoSc 56 22S
--Lab 5
--B.L. Dobbins, E.W. Hansen, Professor Luke
--Your Name Here: Phuc Tran
--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity lab5_controller is
    Port ( 
		--timing:
			clk_port 			: in std_logic;
		--control inputs:
			load_port	      	: in std_logic;
			clear_port          : in std_logic;
		--control outputs:
			term1_en_port	    : out std_logic;
			term2_en_port	    : out std_logic;
			sum_en_port		    : out std_logic;
			reset_port			: out std_logic);
end lab5_controller;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of lab5_controller is
--=============================================================================
--Signal Declarations: 
--=============================================================================
signal term1_en : std_logic:= '0';
signal term2_en : std_logic:= '0';
signal sum_en 	: std_logic:= '0';
signal reset 	: std_logic:= '0';

type state_type is (blank, num1, num2, sum);
signal current_state, next_state : state_type := blank;
--=============================================================================
--Processes: 
--=============================================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Update the current state (synchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
StateUpdate: process(clk_port)
begin
	if rising_edge(clk_port) then
		current_state <= next_state;
	end if;
end process StateUpdate;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NextStateLogic: process(load_port, clear_port)
begin
	next_state <= current_state;

	-- FSM that includes three load_port states (add OP buttons) and a final clear_port state (clear/reset button)
	case(current_state) is
		when blank	=> 	if load_port = '1' then
							next_state <= num1;
					  	end if;
		
		when num1	=> 	if load_port = '1' then 
							next_state <= num2;
					  	end if;
		
		when num2	=> 	if load_port = '1' then
							next_state <= sum;
						end if;
		
		when sum	=>	if clear_port = '1' then
							next_state <= blank;
						end if;

		when Others	=>	next_state <= blank;
	end case;

end process NextStateLogic; 

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
OutputLogic: process(current_state)
begin

	-- handling default values
	term1_en <= '0';
	term2_en <= '0';
	sum_en 	 <= '0';
	reset	 <= '0';

	case(current_state) then

		when num1	=> 	term1_en <= '1';

		when num2	=> 	term2_en <= '1';

		when sum	=>	sum_en   <= '1';

		when blank	=>	reset	 <= '1';
	
	end case;

end process OutputLogic;

-- Asynchronous updates
term1_en_port <= term1_en;
term2_en_port <= term2_en;
sum_en_port   <= sum_en;
reset_port    <= reset;

end behavioral_architecture;