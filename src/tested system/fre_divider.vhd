----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:23:52 05/07/2015 
-- Design Name: 
-- Module Name:    fre_divider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- This is a frequenct divider to divide the 100MHz system clock to 5MHz 
-- Use the countet
entity fre_divider is
	generic(
		counter_width : integer :=5;
		cycle: integer :=19
	);
	
	port(
		CLK: in std_logic;
		CLK_MDC: out std_logic;
		nRST: in std_logic -- global reset signal, can initialize the DFF, active low
	);
end fre_divider;

architecture Behavioral of fre_divider is
			
			component Counter
				generic(
					width: integer :=3;
					max_val: integer :=7
				);
				port(
					CLK: in std_logic;
					nRST: in std_logic;
					EN1: in std_logic;
					EN2: in std_logic;
					COUT: out std_logic -- should be 2.5MHz
				);
			end component;

				signal clock_5M : std_logic; -- We use counter to get 5MHz clock first
				signal MDC_in: std_logic;
				signal MDC_out: std_logic := '1'; -- MDC_out is the register here, the DFF here
	-- Ways we generate a 50% 50% 2.5 MHz clock:
	-- (1) We use Counter to generate a 5MHz positive impulse
	

begin

		clock_5M_counter: Counter
		generic map(
			width => counter_width,
			max_val => cycle
		)
		port map(
			CLK => CLK,		
			nRST => nRST,
			EN1 => '1',
			EN2 => '1',
			COUT => clock_5M
		);


	MDC_in <= not MDC_out;	
	
	process(CLK,nRST) 
		begin
		-- for the same signal MDC_in, all the operations related to it must be put in the same process
		if ( nRST = '0') then
			MDC_out <= '0'; -- we assign value to the register
		else 
			if (rising_edge(CLK)) then
				if clock_5M = '1' then -- 5MHz clock acts as an enable signal
					MDC_out <= MDC_in;
				end if ;
			end if;			
		end if;
	end process;				
	CLK_MDC <= MDC_out;	

 end Behavioral;




