----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:29:59 06/04/2015 
-- Design Name: 
-- Module Name:    shell - Behavioral 
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

entity shell is
	port(
			-- Clock
			CLK : in  STD_LOGIC;
			
			-- Switches and buttons
			SW : in  STD_LOGIC_VECTOR (7 downto 0);
			BTN : in  STD_LOGIC_VECTOR (4 downto 0);
			
			-- Digits
			SSEG_CA : out  STD_LOGIC_VECTOR (7 downto 0);
			SSEG_AN : out  STD_LOGIC_VECTOR (3 downto 0);
				
			-- LED
			LED : out  STD_LOGIC_VECTOR (7 downto 0);
			
			-- UART
			UART_RXD : in std_logic;
			UART_TXD : out std_logic;
			
			-- RAM	
			-- Address bus
			RAM_ADDR : out std_logic_vector(25 downto 0);			
			-- Data bus
			RAM_DATA : inout std_logic_vector(15 downto 0);			
			-- Clock
			RAM_CLK_out : out std_logic;			
			-- Chip enable
			RAM_nCE : out std_logic;			
			-- Write enable
			RAM_nWE : out std_logic;			
			-- Output enable
			RAM_nOE : out std_logic;					
			-- Address valied
			RAM_nADV : out std_logic;			
			-- Control register enable
			RAM_CRE : out std_logic;			
			-- Lower bits enable
			RAM_nLB : out std_logic;
			-- Higher bits enable
			RAM_nUB : out std_logic;			
			-- Wait : Data not valid, active low
			RAM_WAIT_in : in std_logic;
			
			-- PHY
			PHY_MDIO : inout std_logic;
			PHY_MDC : out std_logic;
			PHY_nRESET : out std_logic;
			PHY_COL : in std_logic;
			PHY_CRS : in std_logic;
			
			PHY_TXD : out std_logic_vector(3 downto 0);
			PHY_nINT : out std_logic;
			PHY_TXEN : out std_logic;
			PHY_TXCLK : in std_logic;
			
			PHY_RXD : in std_logic_vector(3 downto 0);
			PHY_RXER : in std_logic;
			PHY_RXDV : in std_logic;
			PHY_RXCLK : in std_logic;
			
		);
end shell;

architecture Behavioral of shell is

begin


end Behavioral;

