----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:42:15 04/12/2015 
-- Design Name: 
-- Module Name:    mii - Behavioral 
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

entity MII is
	port(
		-- Clock and reset
			CLK : in std_logic;
			nRST : in std_logic;		
	
		-- MAC_core_RX		
			-- Data to MAC_core
			RXD_MAC_core : out std_logic_vector(7 downto 0);			
			-- Data to MAC_core is ready to read
			RXDV_MAC_core : out std_logic;		
		
		-- MAC_core_TX		
			-- Data from MAC_core
			TXD_MAC_core : in std_logic_vector(7 downto 0);			
			-- Data is ready to read
			TXDV_MAC_core  : in std_logic;			
			-- Data has been latched, the data can be updated now
			TXDU_MAC_core : out std_logic;			
	
		-- MII_RX		
			-- Data to receive
			RXD : in std_logic_vector(3 downto 0);			
			-- receive error
			RXER : in std_logic;			
			-- receive ready
			RXDV : in std_logic;			
			-- receive clock
			RXCLK : in std_logic;		
		
		-- MII_TX		
			-- Data to transmit
			TXD : out std_logic_vector(3 downto 0);			
			-- transmit error
			TXER : out std_logic;			
			-- transmit enable
			TXEN : out std_logic;			
			-- transmit clock
			TXCLK : in std_logic;			
			
		-- collision indication
			COL : in std_logic;			
		-- carrier sense
			CRS : in std_logic		
		);
end MII;

architecture Behavioral of MII is

begin


end Behavioral;

