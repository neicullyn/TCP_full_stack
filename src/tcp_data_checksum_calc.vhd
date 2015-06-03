----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:09:18 06/02/2015 
-- Design Name: 
-- Module Name:    tcp_data_checksum_calc - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tcp_data_checksum_calc is
	port (
			nRST : in std_logic;
			CLK : in std_logic;
			
			din : in std_logic_vector(15 downto 0);
			wr : in std_logic;
			reset : in std_logic;
			
			checksum_out : out std_logic_vector(15 downto 0)
			);
			
			
end tcp_data_checksum_calc;

architecture Behavioral of tcp_data_checksum_calc is
	signal result : unsigned(15 downto 0);
begin
	checksum_out <= std_logic_vector(result);
	process (nRST, CLK)
	begin
		if (nRST = '0') then
			result <= x"0000";
		elsif (rising_edge(CLK)) then
			if (reset = '1') then
				result <= x"0000";
			elsif (wr = '1') then
				result <= result + unsigned(din);
			end if;
		end if;
	end process;
end Behavioral;

