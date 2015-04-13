----------------------------------------------------------------------------------
-- UART
-- This is an implementation for a UART, which is connected to two FIFOs
--	    	----------------
-- rx -> |					| -> rx_data -> |	rx_FIFO |
--		   |		UART		|
-- tx <- |					| <- tx_data <- | tx_FIFO |
--	   	----------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UART is
	generic( 
			-- Prescaler
			-- UART frequency is system frequency / n_prescaler
			n_prescaler : integer := 434 / 2
			
			);
	port( 
			-- Clock and reset
			CLK : in  std_logic;
			nRST : in std_logic;
			
			-- UART Interface
			RX_serial  : in  std_logic;
			TX_serial  : out std_logic;
			
			-- Databus Interface, connect to FIFOs
			RXD : out std_logic_vector(7 downto 0);
			TXD : in  std_logic_vector(7 downto 0);
			
			-- rx_data is ready for read
			RXDV : out std_logic;
			
			-- tx_data in FIFO is ready to be loaded
			TXDV : in  std_logic
			
			);			
end UART;

architecture Behavioral of UART is

begin


end Behavioral;

