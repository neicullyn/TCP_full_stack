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

			-- Data in transmit FIFO is ready for reading
			TXDV : in std_logic;
			
			-- Data is ready for reading
			RXDV : out std_logic;
			
			-- pulse for writing data to receive FIFO
			WR : out std_logic;
			
			-- pulse for reading data from transmit FIFO
			RD : out  std_logic
			
			);			
end UART;

architecture Behavioral of UART is
	COMPONENT Counter
		GENERIC(
			width : integer := 3;
			max_val : integer := 7
			);
		PORT(
			CLK : IN std_logic;
			nRST : IN std_logic;
			EN1 : IN std_logic;          
			EN2 : IN std_logic;    
			COUT : OUT std_logic
			);
	END COMPONENT;

	------------------------------------------------------------------
	-- Dummy Signals
	signal WR_dummy : std_logic;
	signal RD_dummy : std_logic;
	------------------------------------------------------------------
	
	------------------------------------------------------------------
	-- These are the singals used to generate f_uart and 6 * f_uart
	
	-- main_counter: generate 6 * f_uart
	signal main_counter_overflow : std_logic;
	
	-- rx_aux_counter: generate f_uart for rx
	signal rx_aux_counter_enable :std_logic;
	signal rx_aux_counter_overflow : std_logic;
	
	-- tx_aux_counter: generate f_uart for tx
	signal tx_aux_counter_enable :std_logic;
	signal tx_aux_counter_overflow : std_logic;

	-- These two signal is used to generate the actural 
	-- clock signal for UART module.
	-- They are actually the overflow signals of the counters
	signal clock_valid_UARTx6 : std_logic;
	signal clock_valid_UART_rx : std_logic;
	signal clock_valid_UART_tx : std_logic;
	

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
	
	------------------------------------------------------------------
	-- These are the signals for data transimitting
	signal TX_buf : std_logic_vector(7 downto 0);
	signal TX_counter : unsigned(2 downto 0);
	
	
	type TX_STATES is (IDLE, START, RUN, STOP);
	signal TX_state : TX_STATES;
	------------------------------------------------------------------
begin
	-- Set dummy signals
	WR <= WR_dummy;
	RD <= RD_dummy;

	-- This is the process to generate the clock_valid signal
	-- Both clock_valid_UART and clock_valid_UARTx6 are pulses
	-- enabling the corresponding parts of the circuit.



	main_counter: Counter 
		generic map(
			width => counter_width,
			max_val => n_prescale - 1
			)
		port map(
			CLK => CLK,
			nRST => nRST,
			EN1 => '1',
			EN2 => '1',
			COUT => main_counter_overflow
	);
	
	rx_aux_counter: Counter 
		generic map(
			width => 3,
			max_val => 6- 1
			)
		port map(
			CLK => CLK,
			nRST => nRST,
			EN1 => main_counter_overflow,
			EN2 => rx_aux_counter_enable,
			COUT => rx_aux_counter_overflow
	);
	
	tx_aux_counter: Counter 
		generic map(
			width => 3,
			max_val => 6- 1
			)
		port map(
			CLK => CLK,
			nRST => nRST,
			EN1 => main_counter_overflow,
			EN2 => tx_aux_counter_enable,
			COUT => tx_aux_counter_overflow
	);
	
	
	-- If the clock frequency of UART is 115200:
	-- the frequency of clock_valid_UART ~ 115200
	-- the frequency of clock_Valid_UARTx6 ~ 115200 * 6	
	-- The clock_valid signals for f_uart are the same as overflow signals
	clock_valid_UART_rx <= rx_aux_counter_overflow;
	clock_valid_UART_tx <= tx_aux_counter_overflow;
	clock_valid_UARTx6 <= main_counter_overflow;
	
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
			if (clock_valid_UARTx6 = '1') then
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
	rx_aux_counter_enable <= '1' when (RX_state = RUN or RX_state = STOP) else '0';
	
	RX_Main: process(nRST, CLK)
	begin
		if(nRST = '0') then
			-- Async reset
			WR_dummy <= '0';
			RXDV <= '0';
			RX_state <= IDLE;
			RX_buf <= "00000000";
			RX_counter <= to_unsigned(0, RX_counter'length);
			
		elsif(rising_edge(CLK)) then
			-- the width of wr is one clock
			if (WR_dummy = '1') then
				WR_dummy <= '0';
			end if;
			
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
						if (clock_valid_uart_rx = '1') then
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
						if (clock_valid_uart_rx = '1') then
							WR_dummy <= '1';
							RX_state <= idle;
						end if;					
				end case;
				
			end if;	
		end if;
	end process;
	
	
	tx_aux_counter_enable <= '1' when (TX_state = START or TX_state = RUN or TX_state = STOP) else '0';
	-- This is the process to receive data
	TX_main : process(nRST, CLK)
	begin
		if(nRST = '0') then
			-- Async Reset
			RD_dummy <= '0';
			TX_buf <= "00000000";
			TX_counter <= to_unsigned(0, TX_counter'length);
			TX_state <= IDLE;
		elsif (rising_edge(CLK)) then
			-- The width of RD is one clock cycle
			if (RD_dummy = '1') then
				RD_dummy <= '0';
			end if;
			
			case TX_state is 
				when IDLE =>
					if(TXDV = '1') then						
						-- Buffer the data
						RD_dummy <= '1';
						TX_buf <= TXD;
						
						-- Goto START
						TX_state <= START;
					end if;
				when START =>					
					if (clock_valid_UART_tx = '1') then
						
						-- Clear the TX_counter
						TX_counter <= to_unsigned(0, TX_counter'length);
						TX_state <= RUN;
					end if;
					
				when RUN =>					
					if (clock_valid_UART_tx = '1') then
						-- Increase the counter
						TX_counter <= TX_counter + 1;
						
						if (TX_counter = "111") then
							-- Goto STOP when all bits are transmitted
							TX_state <= STOP;
						else							
							TX_buf <= '0' & TX_buf(7 downto 1);
						end if;
					end if;
				when STOP =>
					if (clock_valid_UART_tx = '1') then
						TX_state <= IDLE;
					end if;
			end case;
		end if;
	end process;
	
	TX_output : process(TX_state, TX_counter, TX_buf)
	begin
		case TX_state is 
			when IDLE =>
				TX_serial <= '1';
			when START =>
				TX_serial <= '0';				
			when RUN =>
				TX_serial <= TX_buf(0);
			when STOP =>
				TX_serial <= '1';
		end case;
	end process;


end Behavioral;

