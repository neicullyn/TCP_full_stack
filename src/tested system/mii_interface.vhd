----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:59:28 04/26/2015 
-- Design Name: 
-- Module Name:    mii_interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- the reason for writing this interface is to meet the chip requirement of MII
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mii_interface is 
port(
		-- Clock controlled by PHY, independent with each other
			CLK: in std_logic;-- system clock
			TXCLK : in std_logic;
			RXCLK : in std_logic;
			nRST: in std_logic;			

			TXDV: in std_logic; -- from MAC, 
			-- TX_DV is given by MAC to decide whether we need to transmit(read out) data from MAC to PHY
			-- when all the data is read out from MAC, it will become invalid which is set by MAC
			TXEN: out std_logic;--transmit enable
			-- when TXEN is valid, MII chip will execute its transmit mode directly
		
			RXDV: in std_logic;--receive valid(enable)
			
			TX_in: in std_logic_vector(7 downto 0);-- transmit mode: data input from MAC
			TXD: out std_logic_vector(3 downto 0); -- transmit mode: data output to PHY
			
			RXD: in std_logic_vector(3 downto 0);-- receive mode: data input from PHY			
			RX_out: out std_logic_vector(7 downto 0);-- receve mode: data output to MAC
			
			WR: out std_logic;-- receive mode: to push a 4-bit data into FIFO, active high
			RD: out std_logic-- transmit mode: to pop a 4-bit data out of FIFO, active high
	 );
end mii_interface;

architecture Behavioral of mii_interface is
	
	-- counters for both directions
	type states is (Idle, First, Second);
	signal TX_state : states := Idle;
	signal RX_state : states := Idle;

	-- data registers
	signal TX_register : STD_LOGIC_VECTOR(7 downto 0);
	signal RX_register : STD_LOGIC_VECTOR(7 downto 0);
	
	-- to generate local clocks
	signal RXCLK_prev :  std_logic; 
	signal TXCLK_prev: std_logic; 
	signal fall_RXCLK:  std_logic;  
	signal fall_TXCLK: std_logic;  

	
begin

	TX_register <= TX_in;
	RX_out <= RX_register;
	
	
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			RXCLK_prev <= RXCLK;
			TXCLK_prev <= TXCLK;
		end if;
   end process;
	

	process(RXCLK, RXCLK_prev)
	begin
		if (RXCLK = '0' and RXCLK_prev = '1') then
			fall_RXCLK <= '1';
		else 
			fall_RXCLK <= '0';
		end if;
	end process;
		
	process(TXCLK, TXCLK_prev)
	begin
		if (TXCLK = '0' and TXCLK_prev = '1') then
			fall_TXCLK <= '1';
		else 
			fall_TXCLK <= '0';
		end if;
	end process;
	
	
	process(CLK, nRST)
	begin
		if (nRST = '0') then
			TX_state <= Idle;
			RX_state <= Idle;
		else
			if (rising_edge(CLK)) then
				case TX_state is
					when Idle =>
						RD <= '0';
						if (TXDV = '1') then
							TXD <= TX_register(7 downto 4);
							TX_state <= First;
							TXEN <= '1';
						else
							TXEN <= '0';
						end if;
					
					when First =>
						RD <= '0';
						TXEN <= '1';
						if (fall_TXCLK = '1') then
							TXD <= TX_register(3 downto 0);
							TX_state <= Second;
						end if;
						
					when Second =>
						if (fall_TXCLK = '1') then											
							RD <= '1';
							if (TXDV = '1') then
								TXD <= TX_register(7 downto 4);
								TX_state <= First;
								TXEN <= '1';
							else
								TX_state <= Idle;
								TXEN <= '0';
							end if;
						else
							RD <= '0';
						end if;

				end case;
							
				case RX_state is
					when Idle =>
						WR <= '0';
						if (fall_RXCLK = '1') then
							if (RXDV = '1') then
								RX_register(7 downto 4) <= RXD;
								RX_state <= First;
							end if;
						end if;
						
					when First =>
						if (fall_RXCLK = '1') then
							if (RXDV = '1') then
								RX_register(3 downto 0) <= RXD;
								RX_state <= Second;
								WR <= '1';
							end if;
						else
							WR <= '0';
						end if;
					
					when Second =>
						WR <= '0';
						if (fall_RXCLK = '1') then
							if (RXDV = '1') then
								RX_register(7 downto 4) <= RXD;
								RX_state <= First;
							else
								RX_state <= Idle;
							end if;
						end if;
						
				end case;
			end if;
		end if;
	end process;
end Behavioral;

