----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:30:46 05/26/2015 
-- Design Name: 
-- Module Name:    MAC - Behavioral 
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
-- 1. No segametion or assembly function implemented. During demonstration, use proper
-- size of packets, or handle that at the application layer.
-- 2. For the transmission, assume the data length is known, otherwise need to buffer
-- the whole packet before transmission. The data length (only the data part, excluding
-- the header part) is in the constant TX_LENGTH
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



entity IP is
    Port ( CLK : in  STD_LOGIC;  -- global clock
           nRST : in  STD_LOGIC;  -- global reset, active low
           TXDV : in  STD_LOGIC; -- transmiision data ready from client layer
			  TXEN : out STD_LOGIC; -- transmission data ready for underlying layer (MAC)
           TXDC : in  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus from client layer via collector
           TXDU : out  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus to underlying layer
           RXDC : out  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus to client layer via dispatcher
           RXDU : in  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus from the underlying layer
			  RXER : out STD_LOGIC; -- receive data error
			 
  			  TXIP : in STD_LOGIC_VECTOR (31 downto 0); -- transmission dst address
			  TXIPEN: in STD_LOGIC; -- transmission IP ready
			  RXIP : out STD_LOGIC_VECTOR (31 downto 0); -- receiving src address
			  RXIPV : out STD_LOGIC; -- receiving src addres valid
			  
           RdC: out STD_LOGIC; -- Read pulse for client layer
			  WrC: out STD_LOGIC; -- Write pulse for client layer
			  RdU: in STD_LOGIC; -- Read pulse from MAC
			  WrU: in STD_LOGIC; -- Write pulse from MAC
           SELT : in  STD_LOGIC; -- Protocol selection via collector during transmission, 0 for TCP, 1 for UDP
	        SELR : out  STD_LOGIC -- Protocol selection via dispatcher during receiving, 0 for TCP, 1 for UDP
           );
end IP;

architecture Behavioral of IP is
	
	-- data length (excluding the header part)
	constant TX_LENGTH : integer := 100;
	signal TX_total_length: STD_LOGIC_VECTOR(15 downto 0);
	signal RX_LENGTH : integer;
	signal RX_total_length: STD_LOGIC_VECTOR(15 downto 0);
	
	
	-- Addresses
	type IP_addr is array(0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
	
	signal IP_src_addr: IP_addr;
	signal IP_dst_addr: IP_addr;
	signal IP_RX_src_addr: IP_addr;
	
	
	-- IP states and counters
	type TX_states is (Idle, Checksum_cal, Header, Payload);
		-- Checksum is calculated in the Checksum phase
	type RX_states is (Idle, Header, Payload);
	
	signal TX_state: TX_states := Idle;
	signal RX_state: RX_states := Idle;
	signal TX_counter: integer := 0;
	signal RX_counter: integer := 0;
	
	-- Dispatcher and Collecotr selection signal
	type client is (TCP, UDP);
	
	signal RX_client: client := TCP;
	
	-- TX and RX registers
	signal TX_register: STD_LOGIC_VECTOR(7 downto 0);
	signal RX_register: STD_LOGIC_VECTOR(7 downto 0);
	
	-- RXER register
	signal ER_register: STD_LOGIC;
	
	-- Header data
	type harray is array (0 to 19) of STD_LOGIC_VECTOR(7 downto 0);
	signal hdata : harray;
	
	-- Checksum calculator
	component CHECKSUM is
   Port (  CLK : in  STD_LOGIC; 
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);   
           nRST : in  STD_LOGIC; 
			  INIT : in STD_LOGIC; 
           D_VALID : in  STD_LOGIC; 
			  CALC: in STD_LOGIC; 
           REQ : in  STD_LOGIC;
			  SELB : in STD_LOGIC;
           CHKSUM : out  STD_LOGIC_VECTOR (7 downto 0)
			  );
	end component;
	
	-- Checksum signals
	signal TXC_DATA: STD_LOGIC_VECTOR(7 downto 0);
	signal RXC_DATA: STD_LOGIC_VECTOR(7 downto 0);
	signal TX_INIT: STD_LOGIC;
	signal RX_INIT: STD_LOGIC;
	signal TX_CALC: STD_LOGIC;
	signal RX_CALC: STD_LOGIC;
	signal TX_D_VALID: STD_LOGIC;
	signal RX_D_VALID: STD_LOGIC;
	signal TX_REQ: STD_LOGIC;
	signal RX_REQ: STD_LOGIC;
	signal TX_SELB: STD_LOGIC;
	signal RX_SELB: STD_LOGIC;
	signal TX_CHKSUM: STD_LOGIC_VECTOR(7 downto 0);
	signal RX_CHKSUM: STD_LOGIC_VECTOR(7 downto 0);
	
begin

	TXCHKSUM: CHECKSUM
	port map(
			  CLK => CLK, 
           DATA => TXC_DATA,   
           nRST => nRST, 
			  INIT => TX_INIT,
           D_VALID => TX_D_VALID, 
			  CALC => TX_CALC, 
           REQ => TX_REQ,
			  SELB => TX_SELB,
           CHKSUM => TX_CHKSUM
	);
	
	RXCHKSUM: CHECKSUM
	port map(
			  CLK => CLK, 
           DATA => RXC_DATA,   
           nRST => nRST, 
			  INIT => RX_INIT,
           D_VALID => RX_D_VALID, 
			  CALC => RX_CALC, 
           REQ => RX_REQ,
			  SELB => RX_SELB,
           CHKSUM => RX_CHKSUM
	);
		
	IP_src_addr <= (X"80",X"10",X"10",X"00"); -- for transmission, src address, fixed
   -- Modify appropriately

	
	RXIP(31 downto 24) <= IP_RX_src_addr(0);  -- MSB
	RXIP(23 downto 16) <= IP_RX_src_addr(1);
	RXIP(15 downto 8) <= IP_RX_src_addr(2);
	RXIP(7 downto 0) <= IP_RX_src_addr(3);
	
	SELR <= '0' when RX_client = TCP else '1'; -- receiving direction, TCP for 0
		
	TXDU <= TX_register;
	RXDC <= RX_register;	
	RXER <= ER_register;
	
	TX_total_length <= std_logic_vector(to_unsigned(TX_LENGTH + 20, 16));
	
	-- hdata: data in header
	hdata(0 to 8) <= (X"45", X"00", TX_total_length(15 downto 8), TX_total_length(7 downto 0), X"00", X"00", X"00", X"00", X"FF");
	hdata(12 to 19) <= (IP_src_addr(0), IP_src_addr(1), IP_src_addr(2), IP_src_addr(3), IP_dst_addr(0), IP_dst_addr(1), IP_dst_addr(2), IP_dst_addr(3));
	
	process(TXIPEN)
	begin
		if (TXIPEN = '1') then
			IP_dst_addr <= (TXIP(31 downto 24), TXIP(23 downto 16), TXIP(15 downto 8), TXIP(7 downto 0));
		end if;			
	end process;
	
	
	-- Main process
	process(nRST, CLK, TXDV, RdU, WrU)
	begin
		if (nRST = '0') then
			-- reset the system state
			RX_client <= TCP;
			TX_state <= Idle;
			RX_state <= Idle;
			TX_counter <= 0;
			RX_counter <= 0;
			TX_INIT <= '0';
			RX_INIT <= '0';
			TX_CALC <= '0';
			RX_CALC <= '0';
			TX_D_VALID <= '0';
			RX_D_VALID <= '0';
			TX_REQ <= '0';
			RX_REQ <= '0';
			ER_register <= '0';
			RXIPV <= '0';
			
		elsif (rising_edge(CLK)) then  -- system triggered by rising edge, modify when necessary
				-- TX direction
				case TX_state is
					when Idle =>
						if (TXDV = '1') then 
							TX_state <= Checksum_cal;
							RdC <= '0';
							RXIPV <= '0';
							TXEN <= '0';
							TX_counter <= 0;
							TX_INIT <= '1';
							TX_SELB <= '1';
							if (SELT = '0') then
								hdata(9) <= X"06";  -- TCP
							else
								hdata(9) <= X"11";  -- UDP
							end if;
							TX_D_VALID <= '0';
							TX_CALC <= '0';
							TX_REQ <= '0';
						end if;
						
					when Checksum_cal =>
						if (TX_counter < 19) then
							TX_INIT <= '0';
							if (TX_counter = 10 or TX_counter = 11) then
								TXC_DATA <= X"00";
							else
								TXC_DATA <= hdata(TX_counter);
							end if;
							TX_SELB <= not TX_SELB;
							TX_D_VALID <= '1';
							if (TX_SELB = '1') then
								TX_CALC <= '1';
							else
								TX_CALC <= '0';
							end if;
							TX_counter <= TX_counter + 1;
							-- The following code is to handle the delay from calculating the CHECKSUM
						elsif (TX_counter = 20) then
							TX_D_VALID <= '0';
							TX_CALC <= '0';
							TX_SELB <= '0';
							TX_REQ <= '1';
							TX_counter <= TX_counter + 1;									
						elsif (TX_counter = 45) then
							hdata(10) <= TX_CHKSUM;
							TX_D_VALID <= '0';
							TX_SELB <= '1';
							TX_REQ <= '1';
							TX_counter <= TX_counter + 1;
						elsif (TX_counter = 80) then
							hdata(11) <= TX_CHKSUM;
							TX_D_VALID <= '0';
							TX_REQ <= '0';
							TX_counter <= 0;
							TX_state <= Header;
							TX_register <= hdata(0);
							TXEN <= '1';
						else
							TX_D_VALID <= '0';
							TX_CALC <= '0';
							TX_counter <= TX_counter + 1;
						end if;
						
						
					when Header =>
						if (RdU = '1') then  -- current data in the register has been handled
							if (TX_counter = 19) then
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
							TX_REQ <= '0';
							TX_CALC <= '0';
							TX_D_VALID <= '0';
						end if;
				end case;
			
				-- RX direction
				case RX_state is
					when Idle =>
						if (WrU = '1') then -- new packet incoming
							RX_counter <= 1;
							RX_state <= Header;
							WrC <= '0';
							RX_SELB <= '0';
							RXC_DATA <= RXDU;
							RX_D_VALID <= '1';
							RX_CALC <= '0';
							RX_REQ <= '0';
							ER_register <= '0';
						else
							WrC <= '0';
							RX_D_VALID <= '0';
							RX_CALC <= '0';
							RX_REQ <= '0';
						end if;
						
					when Header =>
						if (WrU = '1') then
							if (RX_counter < 20) then -- calculate the checksum
 								RX_SELB <= not RX_SELB;
								RXC_DATA <= RXDU;
								RX_D_VALID <= '1';
								if (RX_SELB = '1') then
									RX_CALC <= '1';
								else 
									RX_CALC <= '0';
								end if;
								RX_counter <= RX_counter + 1;
							end if;
								
							if (RX_counter = 20) then  -- RX_counter = 20 or 21 never happens when WrU = '1'
								RX_CALC <= '0';
								RX_D_VALID <= '0';
								RX_SELB <= '0';
								RX_REQ <= '1';
								if (RX_CHKSUM /= X"00") then
									ER_register <= '1';
								end if;								
								RX_counter <= RX_counter + 1;
								
							elsif (RX_counter = 21) then
								RX_CALC <= '0';
								RX_D_VALID <= '0';
								RX_SELB <= '1';
								RX_REQ <= '1';
								if (RX_CHKSUM /= X"00") then
									ER_register <= '1';
								end if;
							
								RX_counter <= 0;
								RX_state <= Payload;
								
							elsif (RX_counter = 2) then
								RX_counter <= RX_counter + 1;
								RX_total_length(15 downto 8) <= RXDU;
							elsif (RX_counter = 3) then
								RX_counter <= RX_counter + 1;
								RX_total_length(15 downto 8) <= RXDU;
							elsif (RX_counter = 4) then
								RX_counter <= RX_counter + 1;
								RX_LENGTH <= to_integer(unsigned(RX_total_length)) - 20;
							elsif (RX_counter = 9) then
								RX_counter <= RX_counter + 1;
								if (RXDU = X"06") then
									RX_client <= TCP;
								else
									RX_client <= UDP;
								end if;
							elsif (RX_counter = 12) then
								RX_counter <= RX_counter + 1;
								IP_RX_src_addr(0) <= RXDU;
							elsif (RX_counter = 13) then
								RX_counter <= RX_counter + 1;
								IP_RX_src_addr(1) <= RXDU;
							elsif (RX_counter = 14) then
								RX_counter <= RX_counter + 1;
								IP_RX_src_addr(2) <= RXDU;
							elsif (RX_counter = 15) then
								RX_counter <= RX_counter + 1;
								IP_RX_src_addr(3) <= RXDU;
								RXIPV <= '1';
							else
								RX_counter <= RX_counter + 1;
							end if;
						else
							RX_D_VALID <= '0';
							RX_CALC <= '0';
							if (RX_counter = 20) then
								RX_SELB <= '0';
								RX_REQ <= '1';
								if (RX_CHKSUM /= X"00") then
									ER_register <= '1';
								end if;
								
								RX_counter <= RX_counter + 1;
								
							elsif (RX_counter = 21) then
								RX_SELB <= '1';
								RX_REQ <= '1';
								if (RX_CHKSUM /= X"00") then
									ER_register <= '1';
								end if;
							
								RX_counter <= 0;
								RX_state <= Payload;
							end if;
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

