----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:10:26 06/04/2015 
-- Design Name: 
-- Module Name:    edge_detect - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity edge_detect is
	port (
			sin : in std_logic;
			srising : out std_logic;
			sfalling : out std_logic;
			CLK : in std_logic
		);
end edge_detect;

architecture Behavioral of edge_detect is
	signal sin_lastval : std_logic;
begin
	process (CLK)
	begin
		if (rising_edge(CLK)) then
			sin_lastval <= sin;
		end if;
	end process;
	
	srising <= '1' when (sin = '1' and sin_lastval = '0') else '0';
	sfalling <= '1' when (sin = '0' and sin_lastval = '1') else '0';

end Behavioral;

