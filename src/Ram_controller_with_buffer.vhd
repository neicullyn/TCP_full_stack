----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:49:38 05/10/2015 
-- Design Name: 
-- Module Name:    Ram_controller_with_buffer - Behavioral 
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

entity Ram_controller_with_buffer is
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
		
	-- Interface with other modules
		nRST : in std_logic;
		CLK : in std_logic
		);
end Ram_controller_with_buffer;

architecture Behavioral of Ram_controller_with_buffer is
	component RAM_Controller
	port(
	-- Interface with RAM
		ADDR : out std_logic_vector(22 downto 0);
		DATA : inout std_logic_vector(15 downto 0);

		CLK_out : out std_logic;
		
		nCE : out std_logic;
		nWE : out std_logic;
		nOE : out std_logic;		
		nADV : out std_logic;
		CRE : out std_logic;
		nLB : out std_logic;
		nUB : out std_logic;
		WAIT_in : in std_logic;		
	
	-- Interface other modules
		CLK : in std_logic;
		nRST : in std_logic;
	
		ADDR_base : in std_logic_vector(22 downto 0);
		N_WORDS : in std_logic_vector (9 downto 0);
		
		
		DIN : in std_logic_vector(15 downto 0);
		DOUT : out std_logic_vector(15 downto 0);
		
		BUSY : out std_logic;
		
		WR : in std_logic;
		RD : in std_logic;

		DINU : out std_logic;
		DOUTV : out std_logic
		
	);
	end component;
	
	signal RAM_ADDR_base : std_logic_vector(22 downto 0);
	signal RAM_N_WORDS : std_logic_vector(9 downto 0);
	signal RAM_DIN : std_logic_vector(15 downto 0);
	signal RAM_DOUT : std_logic_vector(15 downto 0);
	signal RAM_BUSY : std_logic;
	signal RAM_WR : std_logic;
	signal RAM_RD : std_logic;
	signal RAM_DINU : std_logic;
	signal RAM_DOUTV : std_logic;

begin
	RAM_controller_inst : RAM_controller port map(
		ADDR => ADDR,
		DATA => DATA,
		CLK_out => CLK_out,		
		nCE => nCE,
		nWE => nWE, 
		nOE => nOE,
		nADV => nADV,
		CRE => CRE,
		nLB => nLB,
		nUB => nUB,
		WAIT_in => WAIT_in, 
		
		CLK => CLK,
		nRST => nRST,
		
		ADDR_base => RAM_ADDR_base,
		N_WORDS => RAM_N_WORDS,
		DIN => RAM_DIN,
		DOUT => RAM_DOUT,
		BUSY => RAM_BUSY,
		WR => RAM_WR,
		RD => RAM_RD,
		DINU => RAM_DINU,
		DOUTV => RAM_DOUTV
		
		
	);


end Behavioral;

