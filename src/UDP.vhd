----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:30:46 06/01/2015 
-- Design Name: 
-- Module Name:    UDP - Behavioral 
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
-- 1. No checksum is calculated as this requires the whole packet to be available
-- 2. Transmission length is assumed to be known in the constant TX_LENGTH. This length
-- excludes the header part.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity UDP is
    Port ( CLK : in  STD_LOGIC;  -- global clock
           nRST : in  STD_LOGIC;  -- global reset, active low
           TXDV : in  STD_LOGIC; -- transmiision data ready from client layer
			  TXEN : out STD_LOGIC; -- transmission data ready for underlying layer (IP)
           TXDC : in  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus from client layer via collector
           TXDU : out  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus to underlying layer
           RXDC : out  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus to client layer via dispatcher
           RXDU : in  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus from the underlying layer
			  RdC: out STD_LOGIC; -- Read pulse for client layer
			  WrC: out STD_LOGIC; -- Write pulse for client layer
			  RdU: in STD_LOGIC; -- Read pulse from IP
			  WrU: in STD_LOGIC -- Write pulse from IP
           );
end UDP;

architecture Behavioral of UDP is
	
	-- data length (excluding the header part)
	constant TX_LENGTH : integer := 100;
	signal TX_total_length: STD_LOGIC_VECTOR(15 downto 0);
	signal RX_LENGTH : integer;
	signal RX_total_length: STD_LOGIC_VECTOR(15 downto 0);
	
	
	-- Addresses
	type UDP_port is array(0 to 1) of STD_LOGIC_VECTOR(7 downto 0);
	
	signal src_port: UDP_port;
	signal dst_port: UDP_port;
	
	-- UDP states and counters
	type TX_states is (Idle, Header, Payload);
	type RX_states is (Idle, Header, Payload);
	
	signal TX_state: TX_states := Idle;
	signal RX_state: RX_states := Idle;
	signal TX_counter: integer := 0;
	signal RX_counter: integer := 0;
	
	-- TX and RX registers
	signal TX_register: STD_LOGIC_VECTOR(7 downto 0);
	signal RX_register: STD_LOGIC_VECTOR(7 downto 0);
	
	-- Header data
	type harray is array (0 to 7) of STD_LOGIC_VECTOR(7 downto 0);
	signal hdata : harray;
	
begin
		
	src_port <= (X"80",X"10");   -- Modify appropriately
	dst_port <= (X"80",X"11");
	
	TXDU <= TX_register;
	RXDC <= RX_register;	
	
	TX_total_length <= std_logic_vector(to_unsigned(TX_LENGTH + 8, 16));
	
	hdata(0 to 7) <= (src_port(0), src_port(1), dst_port(0), dst_port(1), TX_total_length(15 downto 8), TX_total_length(7 downto 0), X"00", X"00");
	-- Main process
	process(nRST, CLK, TXDV, RdU, WrU)
	begin
		if (nRST = '0') then
			-- reset the system state
			TX_state <= Idle;
			RX_state <= Idle;
			TX_counter <= 0;
			RX_counter <= 0;
			
		elsif (rising_edge(CLK)) then  -- system triggered by rising edge, modify when necessary
				-- TX direction
				case TX_state is
					when Idle =>
						if (TXDV = '1') then 
							TX_state <= Header;
							TX_counter <= 0;
							TX_register <= hdata(0);
							TXEN <= '1';
						end if;
						
					when Header =>
						if (RdU = '1') then  -- current data in the register has been handled
							if (TX_counter = 7) then
								TX_register <= TXDC;
								TX_state <= Payload;
								TX_counter <= 0;
								RdC <= '1';
							else								
								TX_counter <= TX_counter + 1;
								TX_register <= hdata(TX_counter);
								RdC <= '0';
							end if;
						else
							RdC <= '0';
						end if;
		
					when Payload =>
						if (TXDV = '1') then -- Frame not finished
							if (RdU = '1') then
								TX_register <= TXDC;
								RdC <= '1';
							else
								RdC <= '0';
							end if;
						else  -- Frame finished
							if (RdU = '1') then 
								TX_state <= Idle;
								TX_counter <= 0;
								RdC <= '0';
								TXEN <= '0';
							else
								RdC <= '0';
							end if;
						end if;
				end case;
			
				-- RX direction
				case RX_state is
					when Idle =>
						if (WrU = '1') then -- new packet incoming
							RX_counter <= 1;
							RX_state <= Header;
							WrC <= '0';
						else
							WrC <= '0';
						end if;
						
					when Header =>
						if (WrU = '1') then
							if (RX_counter = 7) then
								RX_counter <= 0;
								RX_state <= Payload;
								RX_register <= RXDU;
								WrC <= '1';
							elsif (RX_counter = 4) then
								RX_counter <= RX_counter + 1;
								RX_total_length(15 downto 8) <= RXDU;
							elsif (RX_counter = 5) then
								RX_counter <= RX_counter + 1;
								RX_total_length(15 downto 8) <= RXDU;
							elsif (RX_counter = 6) then
								RX_counter <= RX_counter + 1;
								RX_LENGTH <= to_integer(unsigned(RX_total_length)) - 8;
							else
								RX_counter <= RX_counter + 1;
							end if;
						else
							WrC <= '0';
						end if;
						
					when Payload =>
						if (WrU = '1') then
							if (RX_counter = RX_LENGTH - 1) then -- the last byte of the frame
								RX_counter <= 0;
								RX_register <= RXDU;
								WrC <= '1';
								RX_state <= Idle;								
							else
								RX_counter <= RX_counter + 1;
								RX_register <= RXDU;
								WrC <= '1';
							end if;
						else
							WrC <= '0';
						end if;
				end case;
		end if;
	end process;

end Behavioral;

