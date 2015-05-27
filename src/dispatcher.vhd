----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:32:05 05/27/2015 
-- Design Name: 
-- Module Name:    dispatcher - Behavioral 
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

entity dispatcher is
    Port ( CLK : in  STD_LOGIC;
           nRST : in  STD_LOGIC;
           RXDU : in  STD_LOGIC_VECTOR (7 downto 0);
           WrU : in  STD_LOGIC;
           RXDC1 : out  STD_LOGIC_VECTOR (7 downto 0);
           RXDC2 : out  STD_LOGIC_VECTOR (7 downto 0);
           WrC1 : out  STD_LOGIC;
           WrC2 : out  STD_LOGIC;
           SEL : in  STD_LOGIC);
end dispatcher;

architecture Behavioral of dispatcher is

begin

	process(CLK, nRST, WrU)
	begin
		if (nRST = '0') then
			WrC1 <= '0';
			WrC2 <= '0';
			state <= Idle;
		else
			if (rising_edge(CLK)) then
				if (WrU = '1') then
					if (SEL = '0') then
						RXDC1 <= RXDU;
						WrC1 <= '1';
					else
						RXDC2 <= RXDU;
						WrC2 <= '1';
					end if;
				else
					WrC1 <= '0';
					WrC2 <= '0';
				end if;
			end if;
		end if;
	end process;

end Behavioral;

