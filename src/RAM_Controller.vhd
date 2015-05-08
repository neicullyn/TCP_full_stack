----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:36:42 05/05/2015 
-- Design Name: 
-- Module Name:    RAM_Controller - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_Controller is
	port(
	-- Interface with RAM
	
		-- Address bus
		ADDR : out std_logic_vector(22 downto 0);
		
		-- Data bus
		DATA : inout std_logic_vector(15 downto 0);
		
		-- Control signals
		
		-- Clock
		CLK_out : out std_logic;
		
		-- Chip enable
		nCE : out std_logic;
		
		-- Write enable
		nWE : out std_logic;
		
		-- Output enable
		nOE : out std_logic;		
		
		-- Address valied
		nADV : out std_logic;
		
		-- Control register enable
		CRE : out std_logic;
		
		-- Lower bits enable
		nLB : out std_logic;
		-- Higher bits enable
		nUB : out std_logic;
		
		-- Wait : Data not valid
		-- Active low
		WAIT_in : in std_logic;
		
	
	-- Interface other modules
		-- Clock
		CLK : in std_logic;
		-- Asynchronous reset
		nRST : in std_logic;
	
		-- Start address
		ADDR_base : in std_logic_vector(22 downto 0);
		-- Number of words to be read/write
		N_WORDS : unsigned (10 downto 0);
		
		
		-- Input data and output data
		DIN : in std_logic_vector(15 downto 0);
		DOUT : out std_logic_vector(15 downto 0);
		
		-- Busy signal
		BUSY : out std_logic;
		
		-- Write and read
		WR : in std_logic;
		RD : in std_logic;
		
		-- Both DINU and DOUTV are 1-clock strobe signals
		-- DIN has been latched, needs updating
		DINU : out std_logic;
		-- DOUT is ready, needs storing
		DOUTV : out std_logic
		
	);
end RAM_Controller;

architecture Behavioral of RAM_Controller is
	type STATES is (RESET, SET_BCR, IDLE, READING_WAIT, READING, WRITING_WAIT, WRITING);
	signal state : STATES;
	
	-- ADDR is controlled by a mux, either to output the
	-- actual address, or to output the commands
	type ADDR_MUX_SEL_TYPE is (ADDR_MUX_ADDR, ADDR_MUX_COMMAND);
	signal ADDR_mux_sel : ADDR_MUX_SEL_TYPE;
	
	-- The actual address
	signal ADDR_actual : std_logic_vector(22 downto 0);
	-- The command (used when reset the device)
	signal ADDR_command : std_logic_vector(22 downto 0);
	
	-- The latched ADDR_base
	signal ADDR_base_latched : std_logic_vector(22 downto 0);
	-- The offset of the address from ADDR_base
	signal ADDR_offset : std_logic_vector(10 downto 0);
	
	-- The latched N_WORDS
	signal N_WORDS_LATCHED : unsigned(10 downto 0);
	
	-- The counter that indicates how many words have been
	-- written / read
	signal word_counter : unsigned(10 downto 0);
	
	-- The latched DOUT
	signal DIN_latched : std_logic_vector(15 downto 0);
	
	-- Whether the data output of FPGA is enable
	signal nOE_FPGA : std_logic;
	
begin
	-- No need to divide the frequency
	CLK_out <= CLK;
	
	-- If timing requirement can not be achieved:
	-- CLK_out <= ~ CLK_OUT, per CLK
	-- And use both rising edge and falling edge of
	-- CLK_out, latched data on rising edge, change
	-- data on falling edge
	
	-- The offset is the value of the word counter
	ADDR_offset <= std_logic_vector(word_counter);
	
	-- Only need to output ADDR_base
	ADDR_actual <= ADDR_base_latched;
	
	ADDR_mux : process(ADDR_actual, ADDR_command, ADDR_mux_sel)
	begin
		case (ADDR_mux_sel) is
			when ADDR_MUX_ADDR =>
				-- Output the actual address
				ADDR <= ADDR_actual;
			when ADDR_MUX_COMMAND =>
				-- Output the command
				ADDR <= ADDR_command;		
		end case;	
	end process;
	
	-- We have only one command, make it a constant.
	ADDR_command <=  "000" -- Reserved
						& "10"  -- BCR
						& "00"  -- Reserved
						& '0'   -- Operating Mode : Synchronized
						& '0'   -- Initial Access Latency : Variable
						& "011" -- Variable Latency Counter : 3 (4clocks)
								  -- 100 MHz for -7013, -701 
						& '0'	  -- Wait Polarity : Active Low
						& '0'   -- Reserved
						& '0'   -- WAIT configuartion : Asserted during delay
						& "00"  -- Reserved
						& "01"  -- Drive Strength : 1/2
						& '1'   -- Burst Wrap : No Wrap
						& "111";-- Burst Length : Coninuous Burst	
	
	-- DOUT is the same as DATA, through not always valid
	DOUT <= DATA;
	-- Output DIN to DATA if enable
	DATA <= DIN_latched when nOE_FPGA = '0' else "ZZZZZZZZZZZZZZZZ";
	
	main_proc : process(nRST, CLK)
	begin 
		if (nRST = '0') then
			-- Asynchronous Reset
			
			state <= RESET;
			nOE_FPGA <= '1'; -- Output(FPGA) disable
			BUSY <= '1';   -- Busy
			DINU <= '0';   -- Don't update DIN
			DOUTV <= '0';	-- DOUT not valid
			
			nCE <= '1';		-- Chip disable
			nWE <= '1';		-- Read
			nOE <= '1';		-- Output disable	
			nADV <= '1';	-- Address not valid
			CRE <= '0';		-- Control register disable
			nLB <= '1';		-- Lower bits disable
			nUB <= '1';		-- Hight bits disable
			
			
			ADDR_base_latched <= std_logic_vector(to_unsigned(0, ADDR_base'length));
			word_counter <= to_unsigned(0, word_counter'length);	
			N_WORDS_latched <= to_unsigned(0, N_WORDS_latched'length);
			DIN_latched <= x"0000";
		elsif (rising_edge(CLK)) then
			-- Strobe signals should not be longer than 1 cycle
			DINU <= '0';
			DOUTV <= '0';
			
			case state is
				when RESET =>

					ADDR_mux_sel <= ADDR_MUX_COMMAND;
					
					nCE <= '0';		-- Chip enable
					nWE <= '0';		-- Write
					nOE <= '1';		-- Output disable	
					nADV <= '0';	-- Address valid
					CRE <= '1';		-- Control register enable
					nLB <= '1';		-- Lower bits disable
					nUB <= '1';		-- Hight bits disable					
					state <= SET_BCR;
					
				when SET_BCR =>
					ADDR_mux_sel <= ADDR_MUX_ADDR;
					
					nCE <= '0';		-- Chip enable
					nWE <= '1';		-- Read
					nOE <= '1';		-- Output disable	
					nADV <= '1';	-- Address not valid
					CRE <= '0';		-- Control register disable
					nLB <= '1';		-- Lower bits disable
					nUB <= '1';		-- Hight bits disable	
					
					if (WAIT_in = '1') then
						-- Writing Completed
						nCE <= '1';
						state <= IDLE;
					end if;
					
				when IDLE =>
					if (WR = '0' and RD = '1') then
						-- Going to read
						BUSY <= '1';
						nOE_FPGA <= '1'; -- Output(FPGA) disable
						
						-- Latch the start address and the number of words
						ADDR_base_latched <= ADDR_base;
						N_WORDS_latched <= unsigned(N_WORDS);
						
						word_counter <= to_unsigned(0, word_counter'length);	
						
						nCE <= '0';		-- Chip enable
						nWE <= '1';		-- Read
						nOE <= '0';		-- Output enable	
						nADV <= '0';	-- Address valid
						CRE <= '0';		-- Control register disable
						nLB <= '0';		-- Lower bits enable
						nUB <= '0';		-- Hight bits enable	
						
						state <= READING_WAIT;
					end if;
					if (WR = '1' and RD = '0') then
						-- Going to write
						BUSY <= '1';
						nOE_FPGA <= '0'; -- Output(FPGA) disable
						
						-- DOUT can be updated
						DINU <= '1';
						
						-- Latch the start address and the number of words
						ADDR_base_latched <= ADDR_base;
						N_WORDS_latched <= unsigned(N_WORDS);
						
						-- Latch the output
						DIN_latched <= DIN;
						
						word_counter <= to_unsigned(0, word_counter'length);	
						
						nCE <= '0';		-- Chip enable
						nWE <= '0';		-- Read
						nOE <= '1';		-- Output disable	
						nADV <= '0';	-- Address valid
						CRE <= '0';		-- Control register disable
						nLB <= '0';		-- Lower bits enable
						nUB <= '0';		-- Hight bits enable	
						
						state <= WRITING_WAIT;					
					end if;
					
				when READING_WAIT =>
					-- Wait for another cycle so that WAIT
					-- can be asserted
					nCE <= '0';		-- Chip enable
					nWE <= '1';		-- Read
					nOE <= '0';		-- Output enable	
					nADV <= '1';	-- Address not valid
					CRE <= '0';		-- Control register disable
					nLB <= '0';		-- Lower bits enable
					nUB <= '0';		-- Hight bits enable	
					
					state <= READING;
					
				when READING =>
					if (WAIT_in = '1') then
						-- Not waiting
						if (word_counter + 1 = N_WORDS_latched) then
							-- The last word							
							DOUTV <= '1';	-- DOUT valid
							
							nOE_FPGA <= '1'; -- Output(FPGA) disable
							BUSY <= '0';   -- Not Busy
							
							nCE <= '1';		-- Chip disable
							nWE <= '1';		-- Read
							nOE <= '1';		-- Output disable	
							nADV <= '1';	-- Address not valid
							CRE <= '0';		-- Control register disable
							nLB <= '1';		-- Lower bits disable
							nUB <= '1';		-- Hight bits disable
							
							state <= IDLE;
						else
							-- Not the last word
							DOUTV <= '1';	-- DOUT valid
							word_counter <= word_counter + 1;
						end if;						
					end if;			
				
				when WRITING_WAIT =>
					-- Wait for another cycle so that WAIT
					-- can be asserted
					nCE <= '0';		-- Chip enable
					nWE <= '0';		-- Write
					nOE <= '1';		-- Output disable	
					nADV <= '1';	-- Address not valid
					CRE <= '0';		-- Control register disable
					nLB <= '0';		-- Lower bits enable
					nUB <= '0';		-- Hight bits enable	
					
					state <= WRITING;
				when WRITING =>
					if (WAIT_in = '1') then
						-- Not waiting
						if (word_counter + 1 = N_WORDS_latched) then
							-- The last word							
							
							nOE_FPGA <= '1'; -- Output(FPGA) disable
							BUSY <= '0';   -- Not Busy
							
							nCE <= '1';		-- Chip disable
							nWE <= '1';		-- Read
							nOE <= '1';		-- Output disable	
							nADV <= '1';	-- Address not valid
							CRE <= '0';		-- Control register disable
							nLB <= '1';		-- Lower bits disable
							nUB <= '1';		-- Hight bits disable
							
							state <= IDLE;
						else
							-- Not the last word
							DINU <= '1';	-- DIN can be updated
							DIN_latched <= DIN;
							
							word_counter <= word_counter + 1;
						end if;						
					end if;		
			end case;
		end if;
	end process;

end Behavioral;

