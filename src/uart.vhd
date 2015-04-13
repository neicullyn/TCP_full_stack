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


entity uart is
	generic( 
			-- Prescaler
			-- UART frequency is system frequency / n_prescaler
			n_prescaler : integer := 434 / 2
			
			);
	port( 
			-- Clock
			CLK : in  std_logic;
			
			-- UART Interface
			RX_uart  : in  std_logic;
			TX_uart  : out std_logic;
			
			-- Databus Interface, connect to FIFOs
			RX_bus : out std_logic_vector(7 downto 0);
			TX_bus : in  std_logic_vector(7 downto 0);
			
			-- rx_data is ready for read
			RX_rdy : out std_logic;
			
			-- tx_data in FIFO is ready to be loaded
			TX_rdy : in  std_logic
			
			);			
end uart;

architecture Behavioral of uart is

begin


end Behavioral;

