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
entity lab5_controller_tb is
end entity;

--=============================================================================
--Architecture
--=============================================================================
architecture testbench of lab5_controller_tb is

--=============================================================================
--Component Declaration
--=============================================================================
component lab5_controller is
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
end component;

component lab5_datapath is
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
end component;

--=============================================================================
--Signals
--=============================================================================
-- input signals for controller
signal clk_external:    std_logic:= '0';
signal load_external:   std_logic:= '0';
signal clear_external:  std_logic:= '0';

-- ouput signals for controller and input signals for datapath
signal term1_on_scope:  std_logic:= '0';
signal term2_on_scope:  std_logic:= '0';
signal sum_on_scope:    std_logic:= '0';
signal reset_on_scope:  std_logic:= '0';

-- unique input signal for datapath 
signal term_input_port_external             : std_logic_vector(3 downto 0);

---- output signals for datapath
signal term1_display_on_scope               : std_logic_vector(3 downto 0);
signal term2_display_on_scope               : std_logic_vector(3 downto 0);
signal answer_display_on_scope              : std_logic_vector(3 downto 0);
signal overflow_display_on_scope		    : std_logic;

-- clock constants
--- 10ns = 100 MHz, 1000ns = 1 MHz
constant ext_clk_period: time := 10ns;
constant system_clk_period: time := 1000ns;

begin

--=============================================================================
--Port Map
--=============================================================================
uut: lab5_controller 
	port map(		
		clk_port 		=> clk_external,
		load_port 		=> load_external,
		clear_port 		=> clear_external,
		term1_en_port 	=> term1_on_scope, 
		term2_en_port 	=> term2_on_scope,
		sum_en_port 	=> sum_on_scope,
		reset_port 		=>	reset_on_scope);

dut: lab5_datapath
	port map(		
			clk_port 			 => clk_external,
		    term1_en_port        => term1_on_scope,
		    term2_en_port        => term2_on_scope,
			sum_en_port          => sum_on_scope,
			reset_port           => reset_on_scope,
			term_input_port      => term_input_port_external,
		    term1_display_port   => term1_display_on_scope,
		    term2_display_port   => term2_display_on_scope,
			answer_display_port  => answer_display_on_scope,
			overflow_port		 => overflow_display_on_scope);

--=============================================================================
--clk_100MHz generation (external)
--=============================================================================
--Mimics the clock generation sub-component in the larger design
clkgen_proc: process
begin
	clk_external <= not(clk_external);
    wait for ext_clk_period/2;
end process clkgen_proc;

--=============================================================================
--Stimulus Process
--=============================================================================
stim_proc: process
begin				
    
    -- Initial Slide Values: A = 2 and B = 2
    term_input_port_external <= "0010";
	--++++++++++++++++++++++++++++++++++++++++++
    --Test for first state-- enabling load pulse,which will turn to the next state and lead to a term1_en monopulse
    --++++++++++++++++++++++++++++++++++++++++++
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;

	--++++++++++++++++++++++++++++++++++++++++++
    --Test for second state--enabling load pulse,which will turn to the next state and lead to a term2_en monopulse
    --++++++++++++++++++++++++++++++++++++++++++    
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period;

	--++++++++++++++++++++++++++++++++++++++++++
    --Test for clearing at any state state-- at the second state, clear, which resets all numbers
    --++++++++++++++++++++++++++++++++++++++++++    
    clear_external <= '1';        wait for system_clk_period;
    clear_external <= '0';        wait for system_clk_period;

	--++++++++++++++++++++++++++++++++++++++++++
    --Test for entire first, second, and sum state--should send three mono pulses for first en, second en, and sum en
    --++++++++++++++++++++++++++++++++++++++++++
    -- set term1: 2
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period; 
    load_external  <= '0';        wait for system_clk_period; 

    -- set term2: 2
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period; 

    -- add for sum: 4
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period;
	
	-- clear everything is back to 0
    --++++++++++++++++++++++++++++++++++++++++++    
    clear_external <= '1';        wait for system_clk_period;
    clear_external <= '0';        wait for system_clk_period;

	--++++++++++++++++++++++++++++++++++++++++++
    --Testing 2 and 8 adding operation which should be A with no overflow
    --++++++++++++++++++++++++++++++++++++++++++
    -- set term1: 2
    term_input_port_external <= "0010";
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period; 
    load_external  <= '0';        wait for system_clk_period; 

    -- set term2: 8
    term_input_port_external <= "1000";
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period; 

    -- add for sum: A (10)
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period;
    
    -- clear everything is back to 0
    clear_external <= '1';        wait for system_clk_period;
    clear_external <= '0';        wait for system_clk_period;

	--++++++++++++++++++++++++++++++++++++++++++
    --Testing F (15) and 3 adding operation which should be 2 with overflow
    --++++++++++++++++++++++++++++++++++++++++++
    -- set term1: F (15)
    term_input_port_external <= "1111";
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period; 
    load_external  <= '0';        wait for system_clk_period; 

    -- set term2: 3
    term_input_port_external <= "0011";
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period; 

    -- add for sum: 2 with overflow (important to check)
    load_external  <= '0';        wait for system_clk_period;
    load_external  <= '1';        wait for system_clk_period;
    load_external  <= '0';        wait for system_clk_period;
    
    -- clear everything is back to 0
    clear_external <= '1';        wait for system_clk_period;
    clear_external <= '0';        wait for system_clk_period;  
    wait;
end process stim_proc;

end testbench;