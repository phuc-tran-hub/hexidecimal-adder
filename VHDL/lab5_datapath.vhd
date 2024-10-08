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
entity lab5_datapath is
    Port ( 
		--timing:
			clk_port 			 : in std_logic;
		--control inputs:
		    term1_en_port        : in std_logic;
		    term2_en_port        : in std_logic;
			sum_en_port          : in std_logic;
			reset_port           : in std_logic;
		--datapath inputs:
			term_input_port      : in std_logic_vector(3 downto 0);
		--datapath outputs:
		    term1_display_port   : out std_logic_vector(3 downto 0);
		    term2_display_port   : out std_logic_vector(3 downto 0);
			answer_display_port  : out std_logic_vector(3 downto 0);
			overflow_port		 : out std_logic);
end lab5_datapath;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of lab5_datapath is
--=============================================================================
--Signal Declarations: 
--=============================================================================
signal term1 	: unsigned(3 downto 0):= "0000";
signal term2 	: unsigned(3 downto 0):= "0000";
signal sum 	 	: unsigned(3 downto 0):= "0000";
signal overflow : std_logic:= '0';
--=============================================================================
--Processes: 
--=============================================================================
begin

	comboLogic: process(clk_port)
	begin
		-- synchronously display updates
		if rising_edge(clk_port) then
			-- handling all possible enable ports, this is under the assumption that only one enable port is on at a time 
			-- we don't want to handle '0' cases since we want to save the memory of term 1, term2, and sum
			if reset_port = '1' then
				term1 <= "0000";
				term2 <= "0000";
				sum   <= "0000";
			elsif term1_en_port = '1' then
				term1 <= term_input_port;
			elsif term2_en_port = '1' then
				term2 <= term_input_port;
			elsif sum_en_port = '1' then
				sum   <= term1 + term2;
				
				if sum > 15 then
					overflow <= '1';
				end if;
			end if;
		end if;

	end process comboLogic;

    -- asynchronously connecting our signals to our outputs
	term1_display_port 	 <= std_logic_vector(term1);
	term2_display_port 	 <= std_logic_vector(term2);
	answer_display_port  <= std_logic_vector(sum);
	overflow_port 		 <= std_logic_vector(overflow);

end behavioral_architecture;