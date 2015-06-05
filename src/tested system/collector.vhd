----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:50:11 05/27/2015 
-- Design Name: 
-- Module Name:    collector - Behavioral 
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

entity collector is
    Port ( CLK : in  STD_LOGIC;
           nRST : in  STD_LOGIC;
           TXDU : out  STD_LOGIC_VECTOR (7 downto 0);
           TXEN : out  STD_LOGIC;
           TXDC1 : in  STD_LOGIC_VECTOR (7 downto 0);
           TXDC2 : in  STD_LOGIC_VECTOR (7 downto 0);
           TXDV1 : in  STD_LOGIC;
           TXDV2 : in  STD_LOGIC;
           SEL : out  STD_LOGIC;
			  RdU : in STD_LOGIC;
           RdC1 : out  STD_LOGIC;
           RdC2 : out  STD_LOGIC);
end collector;

architecture Behavioral of collector is

type states is (Idle, Busy);
signal state: states := Idle;
signal TX_register : STD_LOGIC_VECTOR (7 downto 0);
signal SELECTION: STD_LOGIC := '0';

begin
-- Input 1 has priority when contention occurs
	TXDU <= TX_register;
	SEL <= SELECTION;
	
	process(CLK, nRST, RdU)
	begin
		if (nRST = '0') then
			state <= Idle;
			SELECTION <= '0';
			RdC1 <= '0';
			RdC2 <= '0';
		else
			if (rising_edge(CLK)) then
				case state is
					when Idle =>
						RdC1 <= '0';
						RdC2 <= '0';
						if (TXDV1 = '1') then
							TX_register <= TXDC1;
							SELECTION <= '0';
							state <= Busy;
							TXEN <= '1';
						elsif (TXDV2 = '1') then
							TX_register <= TXDC2;
							SELECTION <= '1';
							state <= Busy;
							TXEN <= '1';
						end if;					
					
					when Busy =>
						if (RdU = '1') then
							if (SELECTION = '0') then
								RdC1 <= '1';
							else
								RdC2 <= '1';
							end if;
							
							if (TXDV1 = '1') then
								TX_register <= TXDC1;
								SELECTION <= '0';
								TXEN <= '1';
							elsif (TXDV2 = '1') then
								TX_register <= TXDC2;
								SELECTION <= '1';
								TXEN <= '1';
							else
								TXEN <= '0';
								state <= Idle;
							end if;
						else
							RdC1 <= '0';
							RdC2 <= '0';
						end if;
					
				end case;
			end if;
		end if;
	end process;

end Behavioral;

