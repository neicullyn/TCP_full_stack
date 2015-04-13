----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:42:11 04/12/2015 
-- Design Name: 
-- Module Name:    MDIO - Behavioral 
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

entity MDIO is
	port(
		-- Clock and reset
			CLK : in std_logic;
			nRST : in std_logic;
		
		-- Host interface				
		
		-- MDIO interface		
			-- MDIO clock
			MDC : out std_logic;
			-- MDIO data
			MDIO : inout std_logic
			
		);
end MDIO;

architecture Behavioral of MDIO is

begin


end Behavioral;

