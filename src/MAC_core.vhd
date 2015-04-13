----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:56:46 04/12/2015 
-- Design Name: 
-- Module Name:    MAC_core - Behavioral 
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

entity MAC_core is
	port(
		-- Clock and reset
			CLK : in std_logic;
			nRST : in std_logic;
			
		-- Receive FIFO
			RXD_FIFO : out std_logic_vector(31 downto 0);
			RXD_PUSH : out std_logic;
			
		-- Transmit FIFO
			TXD_FIFO : in std_logic_vector(31 downto 0);
			TXD_POP  : out std_logic;
		
		-- MAC_core_RX		
			-- Data from MII
			RXD_MAC_core : in std_logic_vector(7 downto 0);			
			-- Data from MII is ready to read
			RXDV_MAC_core : in std_logic;		
		
		-- MAC_core_TX		
			-- Data to MII
			TXD_MAC_core : out std_logic_vector(7 downto 0);			
			-- Data to MII is ready to be read
			TXDV_MAC_core : out std_logic;			
			-- Data has been latched, the data can be updated now
			TXDU_MAC_core : in std_logic

			);
end MAC_core;

architecture Behavioral of MAC_core is

begin


end Behavioral;

