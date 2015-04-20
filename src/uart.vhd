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
use IEEE.numeric_std.ALL;


entity UART is
	generic( 
			-- Prescaler
			-- UART frequency is system frequency /(n_prescale * 6)
			-- So n_prescaler should be f_sys / (f_uart * 6)
			-- When f_sys = 100M, f_uart = 115200, n_prescale ~ 144
			n_prescale : integer := 144;
			counter_width : integer := 8
			
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
			TXDV : in  std_logic;
			
			-- ready to transmit new data
			TXRDY : out  std_logic
			
			);			
end UART;

architecture Behavioral of UART is
	------------------------------------------------------------------
	-- These are the singals used to generate f_uart and 6 * f_uart
	
	-- The main counter, which overflow at a frequency of f_uart * 6
	signal main_counter : unsigned ((counter_width-1) downto 0);
	-- The auxiliary counter, which overflow at a frequency of f_uart
	signal aux_counter : unsigned(2 downto 0);
	
		-- The aux_counter is controlled by the enable signal
	signal aux_counter_enable : std_logic;
	
	-- Indicates that main_counter is going to overflow
	signal main_counter_overflow : std_logic;
	-- Indicates that aux_counter is going to overflow
	signal aux_counter_overflow : std_logic;

	-- These two signal is used to generate the actural 
	-- clock signal for UART module.
	-- They are the overflow signals of the counters
	signal clock_valid_UART : std_logic;
	signal clock_valid_UARTx6 : std_logic;
	signal clock_valid_UARTx6b : std_logic;
	------------------------------------------------------------------
	
	------------------------------------------------------------------
	-- These are the signals for input filtering
	
	-- RX_filter_buf are dff that hold the value of RX_serial
	-- They are updated when clock_valid_UARTx6 = '1'
	signal RX_filter_buf : std_logic_vector(0 to 5);
	-- RX_f is the output of the filter
	signal RX_f: std_logic;
	------------------------------------------------------------------
	
	------------------------------------------------------------------
	-- These are the signals for data receiving
	signal RX_buf : std_logic_vector(7 downto 0);
	signal RX_counter : unsigned(2 downto 0);
	
	type RX_STATES is (IDLE, PHASE_ADJUST1, PHASE_ADJUST2, RUN, STOP);
	signal RX_state : RX_STATES;
	------------------------------------------------------------------
	
	


begin
	-- This is the process to generate the clock_valid signal
	-- Both clock_valid_UART and clock_valid_UARTx6 are pulses
	-- enabling the corresponding parts of the circuit.

	-- If the clock frequency of UART is 115200:
	-- the frequency of clock_valid_UART ~ 115200
	-- the frequency of clock_Valid_UARTx6 ~ 115200 * 6
	main_counter_overflow <= '1' when (main_counter = to_unsigned(n_prescale - 1, main_counter'length)) else
									 '0';
	aux_counter_overflow <= '1' when ( (aux_counter = to_unsigned(6 - 1, aux_counter'length))
										        and (main_counter_overflow = '1')) else
									 '0';
	
	-- The clock_valid signals for f_uart are the same as overflow signals
	clock_valid_UART <= aux_counter_overflow;
	clock_valid_UARTx6 <= main_counter_overflow;
	
	-- The phase of the control signal for the filter is different, to avoid side-effect
	clock_valid_UARTx6b <= '1' when (main_counter = to_unsigned((n_prescale - 1) / 2, main_counter'length)) else
									 '0';
									 
	clock_valid_generator: process (nRST, CLK)
	begin
		if (nRST = '0') then
			-- Async reset
			main_counter <= to_unsigned(0, main_counter'length);
			aux_counter <= to_unsigned(0, aux_counter'length);
		elsif (rising_edge(CLK)) then
		
			if (main_counter_overflow = '0') then	
				-- If the counter is not going to overflow, increase the value
				main_counter <= main_counter + 1;
			else
				-- If the counter is going to overflow, the next value is 0
				main_counter <= to_unsigned(0, main_counter'length);
			end if;
			
			if (aux_counter_enable = '1') then
				if (main_counter_overflow = '1') then
					-- Only when main_counter is going to overflow should aux_counter change
					if (aux_counter_overflow = '0') then
						-- If the counter is not going to overflow, increase the value
						aux_counter <= aux_counter + 1;
					else
						-- If the counter is going to overflow, the next value is 0
						aux_counter <= to_unsigned(0, aux_counter'length);
					end if;
				end if;	
			else
				-- Set to 0 when not enabled
				aux_counter <= to_unsigned(0, aux_counter'length);
			end if;
		end if;	
	end process;
	

	-- This is a simple filter to filter out the possible 
	-- noise on RX_serial. RX_serial_f is the output signal,
	-- which is '0' when 4 or more of RX_filter_buf is '0'
	
	-- Since the target device is a Spatan-6, which has
	-- 6-input LUTs, we decide the size of the filter to be 6.
	RX_filter_buf_update: process (nRST, CLK)
	begin
		if (nRST = '0') then
			-- Async reset
			-- Note that the idle state of RX is '1'
			RX_filter_buf <= "111111";
			-- and clock_valid_UARTx6 = '1'
		elsif (rising_edge(CLK)) then
			-- Update the filter buf at a frequency of 6 x f_uart
			if (clock_valid_UARTx6b = '1') then
				-- Rising edge of CLK
				-- Update the buf
				RX_filter_buf(1 to 5) <= RX_filter_buf(0 to 4);
				RX_filter_buf(0) <= RX_serial;			
			end if;
		end if;
	end process;
	
	RX_filter_output: process(RX_filter_buf)
		variable n_zeros : integer range 0 to 6;
	begin
		-- Count the number of zeros
		n_zeros := 0;
		for i in 0 to 5 loop
			if RX_filter_buf(i) = '0' then
				n_zeros := n_zeros + 1;
			end if;
		end loop;
		
		-- If the number of zeros is greater than 4
		-- then the output is zero.
		if (n_zeros >= 4) then
			RX_f <= '0';
		else
			RX_f <= '1';
		end if;		
	end process;
	

	-- This is the process for receiving data
	RXD <= RX_buf;
	aux_counter_enable <= '1' when (RX_state = RUN or RX_state = STOP) else '0';
	
	RX_Main: process(nRST, CLK)
	begin
		if(nRST = '0') then
			-- Async reset
			RXDV <= '0';
			RX_state <= IDLE;
			RX_buf <= "00000000";
			RX_counter <= to_unsigned(0, RX_counter'length);
			
		elsif(rising_edge(CLK)) then
			if (clock_valid_UARTx6 = '1') then
				-- Run at a frequency of f_uart * 6
				case RX_state is
					when IDLE =>
						if (RX_f = '0') then
							-- New data is going to arrive
							-- clear RXDV, go to RUN state
							RXDV <= '0';
							RX_state <= PHASE_ADJUST1;
						end if;
						
					-- Wait for two UARTx6 cycle to adjust the phase
					-- This makes the module more stable
					when PHASE_ADJUST1 =>
						RX_state <= PHASE_ADJUST2;
						
					when PHASE_ADJUST2 =>
						RX_state <= RUN;
						
					when RUN =>
						if (clock_valid_uart = '1') then
							-- Shift register:
							-- RX_f -> RX_buf(7) -> ... -> RX_buf(0)
							RX_buf(6 downto 0) <= RX_buf(7 downto 1);
							RX_buf(7) <= RX_f;
							RX_counter <= RX_counter + 1;						
							
							if (RX_counter = "111") then
								-- When RX_counter = "111", all data have been received
								RXDV <= '1';
								RX_state <= STOP;
							end if;		
						end if;
					
					when STOP =>
						-- Wait for at least one stop bit, then go back to IDLE
						if (clock_valid_uart = '1') then
							RX_state <= idle;
						end if;					
				end case;
				
			end if;	
		end if;
	end process;


end Behavioral;

