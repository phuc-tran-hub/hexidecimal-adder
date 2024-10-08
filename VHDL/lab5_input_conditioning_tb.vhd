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
entity button_interface_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of button_interface_tb is

--=============================================================================
--Component Declaration
--=============================================================================
component button_interface is
    Port( clk_port            : in  std_logic;
		  button_port         : in  std_logic;
		  button_db_port      : out std_logic;
		  button_mp_port      : out std_logic);
end component;

--=============================================================================
--Signals
--=============================================================================
signal clk				: std_logic := '0';
signal button 			: std_logic := '0';
signal debounced 		: std_logic := '0';
signal monopulsed 		: std_logic := '0';

constant clk_period: time := 10 ns;	-- 100 MHz

begin

--=============================================================================
--Port Map
--=============================================================================
uut: button_interface port map(		
		clk_port 			=> clk,		
        button_port 		=> button,
        button_db_port	 	=> debounced,
        button_mp_port	 	=> monopulsed );

--=============================================================================
--clk_100MHz generation 
--=============================================================================
clkgen_proc: process
begin
	clk <= not(clk);		-- toggle clk signal
    wait for clk_period/2;	-- OK to use "wait" in testbench
end process clkgen_proc;

--=============================================================================
--Stimulus Process
--=============================================================================
stim_proc: process
begin				
	--Sit at Input for 10 clk cycles
	wait for 10*clk_period;
	--Bounce:
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	--Settle out at HIGH:
	button <= '1'; wait for 170*clk_period;
	--Bounce:
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	button <= '1'; wait for clk_period;
	button <= '0'; wait for clk_period;
	--Settle out at LOW:
	button <= '0'; wait for 170*clk_period;
	
    wait;
end process stim_proc;

end testbench;