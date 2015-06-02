----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:07:23 06/01/2015 
-- Design Name: 
-- Module Name:    ARP - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity ARP is
    Port ( CLK : in  STD_LOGIC;  -- global clock
           nRST : in  STD_LOGIC;  -- global reset, active low
           TXDV : in  STD_LOGIC; -- transmiision data ready from client layer
			  TXEN : out STD_LOGIC; -- transmission data ready for underlying layer (MAC)
           TXDC : in  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus from client layer via collector
           TXDU : out  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus to underlying layer
           RXDC : out  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus to client layer via dispatcher
           RXDU : in  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus from the underlying layer
			  RdC: out STD_LOGIC; -- Read pulse for client layer
			  WrC: out STD_LOGIC; -- Write pulse for client layer
			  RdU: in STD_LOGIC; -- Read pulse from MAC
			  WrU: in STD_LOGIC -- Write pulse from MAC
           );
end ARP;

architecture Behavioral of ARP is
		
	-- Addresses
	type IP_addr is array(0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
	type MAC_addr is array(0 to 5) of STD_LOGIC_VECTOR(7 downto 0);
	
	signal IP_src_addr: IP_addr;
	signal MAC_src_addr: MAC_addr;
	
	-- ARP states and counters
	type TX_states is (Idle, Header, Request);
	type RX_states is (Idle, Header, Response);
	
	signal TX_state: TX_states := Idle;
	signal RX_state: RX_states := Idle;
	signal TX_counter: integer := 0;
	signal RX_counter: integer := 0;
	
	-- TX and RX registers
	signal TX_register: STD_LOGIC_VECTOR(7 downto 0);
	signal RX_register: STD_LOGIC_VECTOR(7 downto 0);
	
	-- Header data
	type harray is array (0 to 23) of STD_LOGIC_VECTOR(7 downto 0);
	signal hdata : harray;
	
begin
		
	IP_src_addr <= (X"80", X"10", X"20", X"30");   -- Modify appropriately
	MAC_src_addr <= (X"80", X"11", X"80", X"11", X"80", X"11");
	
	TXDU <= TX_register;
	RXDC <= RX_register;	
	
	hdata(0 to 7) <= (X"00", X"01", X"08", X"00", X"06", X"04", X"00", X"01");
	hdata(8 to 13) <= (MAC_src_addr(0), MAC_src_addr(1), MAC_src_addr(2), MAC_src_addr(3), MAC_src_addr(4), MAC_src_addr(5));
	hdata(14 to 17) <= (IP_src_addr(0), IP_src_addr(1), IP_src_addr(2), IP_src_addr(3));
	hdata(18 to 23) <= (X"00", X"00", X"00", X"00", X"00", X"00");
	
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
							if (TX_counter = 23) then
								TX_register <= TXDC;
								TX_state <= Request;
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
		
					when Request =>
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
							RX_counter <= 0;
							RX_state <= Header;
							WrC <= '0';
						else
							WrC <= '0';
						end if;
						
					when Header =>
						if (WrU = '1') then
							if (RX_counter = 17) then
								RX_counter <= 0;
								RX_state <= Response;
								RX_register <= RXDU;
								WrC <= '1';
							else
								RX_counter <= RX_counter + 1;
								WrC <= '0';
							end if;
						else
							WrC <= '0';
						end if;
						
					when Response =>
						if (WrU = '1') then
							if (RX_counter = 5) then 
								RX_counter <= RX_counter + 1;
								WrC <= '0';				
							elsif (RX_counter = 9) then -- last byte of the frame
								RX_counter <= 0;
								RX_state <= Idle;
								WrC <= '0';
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

