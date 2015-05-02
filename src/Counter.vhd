----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:41:50 05/02/2015 
-- Design Name: 
-- Module Name:    Counter - Behavioral 
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
use IEEE.numeric_std.ALL;

entity Counter is
	generic(
			-- The width of the counter
			width : integer := 3;
			-- The maximum value of the counter
			-- The counter counts from 0 to max_val
			max_val : integer := 7
			);
	port(
			-- Clock
			CLK : in std_logic;
			-- Asynchronous reset, active low
			nRST : in std_logic;		
			-- Enable counting and carry out
			EN : in std_logic;
			-- Carry out, is high when val == max_val and EN = '1'
			COUT : out std_logic
			);	
end Counter;

architecture Behavioral of Counter is

	signal val : unsigned((width - 1) downto 0);

begin
	process (nRST, CLK)
	begin
		if (nRST = '0') then
			-- Aysnchronous reset
			val <= to_unsigned(0, val'length);			
		elsif (rising_edge(CLK)) then
			if (EN = '1') then
				-- Counts if enable
				if ( val /= max_val) then
					-- If val != max_val, the next value is val + 1
					val <= val + 1;
				else
					-- If val == max_val, the next value is zero
					val <= to_unsigned(0, val'length);
				end if;
			end if;
		end if;
	end process;
	
	COUT <= '1' when (val = max_val and EN = '1') else '0';
end Behavioral;

