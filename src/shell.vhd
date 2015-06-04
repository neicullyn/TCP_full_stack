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
			RAM_ADDR : out std_logic_vector(25 downto 0);			
			RAM_DATA : inout std_logic_vector(15 downto 0);			
			RAM_CLK_out : out std_logic;			
			RAM_nCE : out std_logic;			
			RAM_nWE : out std_logic;			
			RAM_nOE : out std_logic;					
			RAM_nADV : out std_logic;			
			RAM_CRE : out std_logic;			
			RAM_nLB : out std_logic;
			RAM_nUB : out std_logic;			
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
			PHY_RXCLK : in std_logic
			
		);
end shell;

architecture Behavioral of shell is
    COMPONENT MDIO_interface
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         CLK_MDC : OUT  std_logic;
         data_MDIO : INOUT  std_logic;
         busy : OUT  std_logic;
         nWR : IN  std_logic;
         nRD : IN  std_logic
        );
    END COMPONENT;
	
	COMPONENT edge_detect
	PORT(
		sin : IN std_logic;
		CLK : IN std_logic;          
		srising : OUT std_logic;
		sfalling : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT btn_debounce
	PORT(
		BTN_I : IN std_logic_vector(4 downto 0);
		CLK : IN std_logic;          
		BTN_O : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;
	
	
	--- DEBUG
	COMPONENT fre_divider
	PORT(
		CLK : IN std_logic;
		nRST : IN std_logic;          
		CLK_MDC : OUT std_logic;
		CLK_5M : OUT std_logic
		);
	END COMPONENT;
	
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
	
	signal nRST : std_logic;
	
	-- Signal for buttons
	signal BTN_db : std_logic_vector(4 downto 0); -- Debounced button signal
	signal BTN_dly : std_logic_vector(4 downto 0); -- Delayed button signal
	signal BTN_r : std_logic_vector(4 downto 0); -- Rising edge of buttons
	signal BTN_f : std_logic_vector(4 downto 0); -- Falling edge of buttons
	
	-- Signal for MDIO
	signal MDIO_busy : std_logic;
	signal MDIO_nWR : std_logic;
	signal MDIO_nRD : std_logic;
	
	
	--- DEBUG
	signal flip : std_logic;
begin
	SSEG_CA <= (others => '0');
	SSEG_AN <= (others => '1');
	
	LED <= (0 => MDIO_busy, 1 => flip, 2 => BTN_db(0), others => '0');
	
	UART_TXD <= '1';
	
	RAM_ADDR <= (others => '0');
	RAM_CLK_out <= '0';
	RAM_nCE <= '1';
	RAM_nWE <= '1';
	RAM_nOE <= '1';
	RAM_nADV <= '1';
	RAM_CRE <= '0';
	RAM_nLB <= '1';
	RAM_nUB <= '1';
	
	PHY_nRESET <= '1';
	PHY_TXD <= (others => '0');
	PHY_nINT <= '1';
	PHY_TXEN <= '0';	

	nRST <= not BTN(4);
	
	-- Buttons
	process (CLK)
	begin
		if(BTN_r(0) = '1') then
			flip <= not flip;
		end if;
	end process;
	Inst_btn_debounce: btn_debounce PORT MAP(
		BTN_I => BTN,
		CLK => CLK,
		BTN_O => BTN_db
	);
	
	process(CLK)
	begin
		if(rising_edge(CLK)) then
			BTN_dly <= BTN_db;
		end if;
	end process;
	
	process(BTN_dly, BTN_db)
	begin
		for i in 0 to 4 loop
			if (BTN_db(i) = '1' and BTN_dly(i) = '0') then
				-- 0 -> 1 : Rising edge
				BTN_r(i) <= '1';
			else
				BTN_r(i) <= '0';
			end if;
			
			if (BTN_db(i) = '0' and BTN_dly(i) = '1') then
				-- 0 -> 1 : Falling edge
				BTN_f(i) <= '1';
			else
				BTN_f(i) <= '0';
			end if;
		end loop;
	end process;
	
	

	
	-- MDIO 
    mdio_interface_inst: MDIO_interface PORT MAP (
          CLK => CLK,
          nRST => nRST,
          CLK_MDC => PHY_MDC,
          data_MDIO => PHY_MDIO,
          busy => MDIO_busy,
          nWR => MDIO_nWR,
          nRD => MDIO_nRD
        );
	
	MDIO_nWR <= not BTN_r(0);
	MDIO_nRD <= '1';

end Behavioral;

