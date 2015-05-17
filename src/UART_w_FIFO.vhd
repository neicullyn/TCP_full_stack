----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:02:28 05/17/2015 
-- Design Name: 
-- Module Name:    UART_w_FIFO - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_w_FIFO is
	port(
			-- Asynchronous reset
			nRST : in std_logic;
			-- CLK
			CLK : in std_logic;
			
			-- UART interface
			RX_serial : in std_logic;
			TX_serial : out std_logic;
			
			-- Input Buffer
			DIN : in std_logic_vector(7 downto 0);
			WR : in std_logic;
			FULL : out std_logic;
			
			-- Output Buffer			
			DOUT : out std_logic_vector(7 downto 0);
			RD : in std_logic;
			DOUTV : out std_logic
			
			);
			
			
end UART_w_FIFO;

architecture Structural of UART_w_FIFO is
    COMPONENT UART
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         RX_serial : IN  std_logic;
         TX_serial : OUT  std_logic;
         RXD : OUT  std_logic_vector(7 downto 0);
         TXD : IN  std_logic_vector(7 downto 0);
         RXDV : OUT  std_logic;
         TXDV : IN  std_logic;
			wr : out std_logic;
			rd : out  std_logic
        );
    END COMPONENT;
	 
	COMPONENT FIFO
	PORT(
		nRST : IN std_logic;
		CLK : IN std_logic;
		DIN : IN std_logic_vector(7 downto 0);
		PUSH : IN std_logic;
		POP : IN std_logic;          
		DOUT : OUT std_logic_vector(7 downto 0);
		EMPTY : OUT std_logic;
		FULL : OUT std_logic
		);
	END COMPONENT;
	
	signal RD_UART : std_logic;
	signal WR_UART : std_logic;
	
	signal TXD : std_logic_vector(7 downto 0);
	signal RXD : std_logic_vector(7 downto 0);
	
	signal TXDV : std_logic;
	signal RXDV : std_logic;
	
	signal TX_PUSH : std_logic;
	signal TX_POP : std_logic;
	signal TX_EMPTY : std_logic;
	signal TX_FULL :std_logic;
	
	signal RX_PUSH : std_logic;
	signal RX_POP : std_logic;
	signal RX_EMPTY : std_logic;
	signal RX_FULL :std_logic;
begin
	uut: UART PORT MAP (
          CLK => CLK,
          nRST => nRST,
          RX_serial => RX_serial,
          TX_serial => TX_serial,
          RXD => RXD,
          TXD => TXD,
          RXDV => RXDV,
          TXDV => TXDV,
			 WR => WR_UART,
			 RD => RD_UART
        );
		  
	TX_FIFO: FIFO PORT MAP(
		nRST => nRST,
		CLK => CLK,
		DIN => DIN,
		DOUT => TXD,
		PUSH => TX_PUSH,
		POP => TX_POP,
		EMPTY => TX_EMPTY,
		FULL => TX_FULL
	);
	
	RX_Inst_FIFO: FIFO PORT MAP(
		nRST => nRST,
		CLK => CLK,
		DIN => RXD,
		DOUT => DOUT,
		PUSH => RX_PUSH,
		POP => RX_POP,
		EMPTY => RX_EMPTY,
		FULL => RX_FULL
	);
	
	TX_PUSH <= WR;
	TX_POP <= RD_UART;
	FULL <= TX_FULL;
	
	TXDV <= not TX_EMPTY;	
	
	RX_PUSH <= WR_UART;
	RX_POP <= RD;
	DOUTV <= not RX_EMPTY;

end Structural;

