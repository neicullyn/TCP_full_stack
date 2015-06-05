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
	
	COMPONENT UART_w_FIFO
	PORT(
		nRST : IN std_logic;
		CLK : IN std_logic;
		RX_serial : IN std_logic;
		DIN : IN std_logic_vector(7 downto 0);
		WR : IN std_logic;
		RD : IN std_logic;          
		TX_serial : OUT std_logic;
		FULL : OUT std_logic;
		DOUT : OUT std_logic_vector(7 downto 0);
		DOUTV : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT MAC
	PORT(
		CLK : IN std_logic;
		nRST : IN std_logic;
		TXDV : IN std_logic;
		TXDC : IN std_logic_vector(7 downto 0);
		RXDU : IN std_logic_vector(7 downto 0);
		MDIO_Busy : IN std_logic;
		RdU : IN std_logic;
		WrU : IN std_logic;
		SELT : IN std_logic;          
		TXEN : OUT std_logic;
		TXDU : OUT std_logic_vector(7 downto 0);
		RXDC : OUT std_logic_vector(7 downto 0);
		RXER : OUT std_logic;
		MDIO_nWR : OUT std_logic;
		MDIO_nRD : OUT std_logic;
		RdC : OUT std_logic;
		WrC : OUT std_logic;
		SELR : OUT std_logic;
		TXCLK_f : IN std_logic
		);
	END COMPONENT;
	
	COMPONENT mii_interface
	PORT(
		CLK : IN std_logic;
		TXCLK : IN std_logic;
		RXCLK : IN std_logic;
		nRST : IN std_logic;
		TXDV : IN std_logic;
		RXDV : IN std_logic;
		TX_in : IN std_logic_vector(7 downto 0);
		RXD : IN std_logic_vector(3 downto 0);          
		TXEN : OUT std_logic;
		TXD : OUT std_logic_vector(3 downto 0);
		RX_out : OUT std_logic_vector(7 downto 0);
		WR : OUT std_logic;
		RD : OUT std_logic;
		TXCLK_f : OUT std_logic
		);
	END COMPONENT;
	
	
	
	signal nRST : std_logic;
	
	
	-- Signal for UART
	signal UART_DIN : std_logic_vector(7 downto 0);
	signal UART_WR : std_logic;
	signal UART_FULL : std_logic;
	
	signal UART_DOUT : std_logic_vector(7 downto 0);
	signal UART_RD : std_logic;
	signal UART_DOUTV : std_logic;
	
	
	-- Signal for buttons
	signal BTN_db : std_logic_vector(4 downto 0); -- Debounced button signal
	signal BTN_dly : std_logic_vector(4 downto 0); -- Delayed button signal
	signal BTN_r : std_logic_vector(4 downto 0); -- Rising edge of buttons
	signal BTN_f : std_logic_vector(4 downto 0); -- Falling edge of buttons
	
	-- Signals for MDIO
	signal MDIO_busy : std_logic;
	signal MDIO_nWR : std_logic;
	signal MDIO_nRD : std_logic;
	
	-- Signals for MAC
	signal MAC_TXDV : std_logic;
	signal MAC_TXEN : std_logic;
	signal MAC_TXDC : std_logic_vector(7 downto 0);
	signal MAC_TXDU : std_logic_vector(7 downto 0);
	signal MAC_RXDC : std_logic_vector(7 downto 0);
	signal MAC_RXDU : std_logic_vector(7 downto 0);
	signal MAC_RXER : std_logic;
	signal MAC_RdC : std_logic;
	signal MAC_WrC : std_logic;
	signal MAC_RdU : std_logic;
	signal MAC_WrU : std_logic;
	signal MAC_SELT : std_logic;
	signal MAC_SELR : std_logic;	
	signal MAC_TXCLK_f : std_logic;
	
	
	--- DEBUG
	signal flip : std_logic;
	signal busy_test : std_logic;
	signal MDIO_MDIO : std_logic;
	
	signal PHY_TXEN_dummy : std_logic;
	signal MAC_TXEN_r : std_logic;
	signal MAC_TXEN_f : std_logic;
begin
	
	PHY_TXEN <= PHY_TXEN_dummy;
	SSEG_CA <= (others => '0');
	SSEG_AN <= (others => '1');
	
	PHY_MDIO <= MDIO_MDIO;
	LED <= (0 => UART_DOUTV, 1 => MAC_TXEN, 2 => PHY_TXEN_dummy,
			3 => MAC_RdU, 4 => MAC_RdC, others => '0');
	
	RAM_ADDR <= (others => '0');
	RAM_CLK_out <= '0';
	RAM_nCE <= '1';
	RAM_nWE <= '1';
	RAM_nOE <= '1';
	RAM_nADV <= '1';
	RAM_CRE <= '0';
	RAM_nLB <= '1';
	RAM_nUB <= '1';
	
	PHY_nRESET <= nRST;
	PHY_nINT <= '1';

	
	Inst_UART_w_FIFO: UART_w_FIFO PORT MAP(
		nRST => nRST,
		CLK => CLK,
		RX_serial => UART_RXD,
		TX_serial => UART_TXD,
		DIN => UART_DIN,
		WR => UART_WR,
		FULL => UART_FULL,
		DOUT => UART_DOUT,
		RD => UART_RD,
		DOUTV => UART_DOUTV
	);	

	nRST <= not BTN(4);
	
	process (CLK)
	begin
		if(BTN_r(0) = '1') then
			flip <= not flip;
		end if;		
	end process;
	
	process (nRST, CLK)
	begin
		if (nRST = '0') then
			busy_test <= '1';
		elsif (rising_edge(CLK)) then
			if (MDIO_busy = '1') then
				busy_test <= '0';
			end if;
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
          data_MDIO => MDIO_MDIO,
          busy => MDIO_busy,
          nWR => MDIO_nWR,
          nRD => MDIO_nRD
        );
		
	-- MAC
	Inst_MAC: MAC PORT MAP(
		CLK => CLK,
		nRST => nRST,
		TXDV => MAC_TXDV,
		TXEN => MAC_TXEN,
		TXDC => MAC_TXDC,
		TXDU => MAC_TXDU,
		RXDC => MAC_RXDC,
		RXDU => MAC_RXDU,
		RXER => MAC_RXER,
		MDIO_Busy => MDIO_Busy,
		MDIO_nWR => MDIO_nWR,
		MDIO_nRD => MDIO_nRD,
		RdC => MAC_RdC,
		WrC => MAC_WrC,
		RdU => MAC_RdU,
		WrU => MAC_WrU,
		SELT => MAC_SELT,
		SELR => MAC_SELR,
		TXCLK_f => MAC_TXCLK_f
	);
	
	-- MII	
	Inst_mii_interface: mii_interface PORT MAP(
		CLK => CLK,
		TXCLK => PHY_TXCLK,
		RXCLK => PHY_RXCLK,
		nRST => nRST,
		TXDV => MAC_TXEN,
		TXEN => PHY_TXEN_dummy,
		RXDV => PHY_RXDV,
		TX_in => MAC_TXDU,
		TXD => PHY_TXD,
		RXD => PHY_RXD,
		RX_out => MAC_RXDU,
		WR => MAC_WrU,
		RD => MAC_RdU,
		TXCLK_f => MAC_TXCLK_f
	);
	MAC_SELT <= '0';
	
	MAC_TXDV <= UART_DOUTV;	
	MAC_TXDC <= UART_DOUT;
	UART_RD <= MAC_RdC;
	
	UART_DIN <= MAC_TXDU;
	UART_WR <= MAC_RdU;
	
	
	edge_detect_inst : edge_detect
	port map(
					CLK => CLK,
					sin => MAC_TXEN,
					srising => MAC_TXEN_r,
					sfalling => MAC_TXEN_f
				);
														
	

end Behavioral;

