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

			TX_DV: in std_logic; -- from MAC, 
			-- TX_DV is given by MAC to decide whether we need to transmit(read out) data from MAC to PHY
			-- when all the data is read out from MAC, it will become invalid which is set by MAC
			TXEN: out std_logic;--transmit enable
			-- when TXEN is valid, MII chip will execute its transmit mode directly
		
			RXDV: in std_logic;--receive valid(enable)
			
			TX_in: in std_logic_vector(3 downto 0);-- transmit mode: data input from MAC
			TXD: out std_logic_vector(3 downto 0); -- transmit mode: data output to PHY
			
			RXD: in std_logic_vector(3 downto 0);-- receive mode: data input from PHY			
			RX_out: out std_logic_vector(3 downto 0);-- receve mode: data output to MAC
			
			WR: out std_logic;-- receive mode: to push a 4-bit data into FIFO, active high
			RD: out std_logic-- transmit mode: to pop a 4-bit data out of FIFO, active high
			-- WR and RD is the control signal inside MAC specifically to update the FIFO
			-- WR: in receive mode to push data into FIFO, when writing and updating in the same state
			-- RD: in transmit mode to pop data out of FIFO, reading out first and in the next state, we update the FIFO
	 );
end mii_interface;

architecture Behavioral of mii_interface is
--FSM
	type states is (
		IDLE,
		State1,
		State2);
-- the FSM is only used in transmit mode

	signal state_current: states:=IDLE;

	
	signal RXCLK_pre :  std_logic; -- used as output of DFF to generate a local RX clock for MII
	signal TXCLK_pre: std_logic; -- used as output of DFF to generate a local TX clock for MII
	signal fall_RCLK:  std_logic; -- 
	signal fall_TCLK: std_logic; -- 
	

	

begin
		
		
		TXD<=TX_in; -- act as the data bus, they are always connected
		RX_out<=RXD;
	
	-- 	
	p1: process(CLK)
	begin
		if rising_edge(CLK) then
			RXCLK_pre<=RXCLK;
		end if;
   end process p1;
		
	p2: process(CLK)
	begin
		if rising_edge(CLK) then
		TXCLK_pre<=TXCLK;
		end if;
	end process p2;
		
	
	-- to generate a fall_CLK at the falling edge of RXCLK
	-- This is to drive WR signal
	-- receive mode: PHY to MAC
		process(RXCLK,RXCLK_pre)
		begin
		if RXCLK='0' and RXCLK_pre='1' then
			fall_RCLK<='1';
		else 
			fall_RCLK<='0';
		end if ;
		end process;
		
		-- main process for receive mode
		process(fall_RCLK,RXDV)
		begin
		if (fall_RCLK='1') and (RXDV='1') then
			WR<='1'; -- WR valid
		else 
			WR<='0';
		end if;
		end process;

	-- to generate a fall_TCLK at the falling edge of TXCLK
	-- This is to drive RD signal
		process(TXCLK,TXCLK_pre)
		begin
		if TXCLK='0' and TXCLK_pre='1' then
		fall_TCLK<='1';
		else
		fall_TCLK<='0';
		end if;
		end process;
		
		-- main process for transmit mode		
		process(CLK,nRST)
		begin
		if nRST='0' then
			state_current<=IDLE;

		elsif (rising_edge(CLK)) then
		
		 case state_current is 
			when IDLE =>
			if TX_DV='1' then
				state_current<=State1;
			end if;
			
			when State1 =>
				
			if fall_TCLK='1' then -- TXEN should be valid when there is falling edge of TX_CLK
				TXEN<='1';
				state_current<=State2;
			end if;
				
			when State2 =>

			if TX_DV='1' and fall_TCLK='1' then -- FIFO should be updated when there is falling edge of TX_CLK
				RD<='1';
				state_current<=State2;
			elsif TX_DV='0' then --when all the data is read out
				state_current<=IDLE;
			end if;
			
			end case;
		end if;
		end process;
			
end Behavioral;

