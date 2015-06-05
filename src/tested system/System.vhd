----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:27:45 06/04/2015 
-- Design Name: 
-- Module Name:    System - Behavioral 
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

entity System is
    Port ( CLK : in  STD_LOGIC;
           nRST : in  STD_LOGIC;
           TXDUDP : in  STD_LOGIC_VECTOR (7 downto 0);
			  TXDTCP : in  STD_LOGIC_VECTOR (7 downto 0);
           TXDVUDP : in  STD_LOGIC;
			  TXDVTCP : in  STD_LOGIC;
			  RXDUDP : out STD_LOGIC_VECTOR (7 downto 0);
			  RXDTCP : out STD_LOGIC_VECTOR (7 downto 0);
			  TXDPHY : out STD_LOGIC_VECTOR (3 downto 0);
			  TXEN : out STD_LOGIC;
           RXDPHY : in  STD_LOGIC_VECTOR (3 downto 0);
           RXDVPHY : in  STD_LOGIC;
			  RdUDP : out STD_LOGIC;
			  WrUDP : out STD_LOGIC;
			  RdTCP : out STD_LOGIC;
			  WrTCP : out STD_LOGIC;
			  TXCLK : in STD_LOGIC;
			  RXCLK : in STD_LOGIC;
			  CLK_MDC : out STD_LOGIC;
			  data_MDIO : inout STD_LOGIC;
			  TXIP : in STD_LOGIC_VECTOR (31 downto 0);
			  TXIPEN : in STD_LOGIC
			  );
end System;

architecture Behavioral of System is

component IP is
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
end component;

component ARP is
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
end component;

component MAC is
    Port ( CLK : in  STD_LOGIC;  -- global clock
           nRST : in  STD_LOGIC;  -- global reset, active low
           TXDV : in  STD_LOGIC; -- transmiision data ready from client layer
			  TXEN : out STD_LOGIC; -- transmission data ready for underlying layer (MII)
           TXDC : in  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus from client layer via collector
           TXDU : out  STD_LOGIC_VECTOR (7 downto 0); -- transmission data bus to underlying layer
           RXDC : out  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus to client layer via dispatcher
           RXDU : in  STD_LOGIC_VECTOR (7 downto 0); -- receive data bus from the underlying layer
			  RXER : out STD_LOGIC; -- receive data error-- will be set 1 if there is an error tested by CRC
           MDIO_Busy : in  STD_LOGIC; -- MDIO busy signal
           MDIO_nWR : out  STD_LOGIC; -- MDIO writing control, active low
           MDIO_nRD : out  STD_LOGIC; -- MDIO reading control, active low
			  RdC: out STD_LOGIC; -- Read pulse for client layer
			  WrC: out STD_LOGIC; -- Write pulse for client layer
			  RdU: in STD_LOGIC; -- Read pulse from MII
			  WrU: in STD_LOGIC; -- Write pulse from MII
           SELT : in  STD_LOGIC; -- Protocol selection via collector during transmission, 0 for IP, 1 for ARP
			  -- from collector
           SELR : out  STD_LOGIC -- Protocol selection via dispatcher during receiving, 0 for IP, 1 for ARP
			  -- to dispatcher
           );
end component;

component MDIO_interface is
	port(
			CLK: in std_logic; -- the system clock 100MHz
			nRST: in std_logic; -- reset signal, should be a global signal
			
			-- CLK_MDC and data_MDIO are wires connected to PHY
			CLK_MDC: out std_logic; -- 2.5 MHz clock, to PHY
			data_MDIO: inout std_logic; -- between MDIO interface and PHY
			
			busy: out std_logic; -- indicate that the configuration hasn't finished, to MAC
			
			-- nWR and nRD are from the controller of MDIO
			nWR: in std_logic;-- input signal to identify whether data should be wrtten into PHY, active low
			nRD: in std_logic-- input signal to identify whether data should be read out from PHY, active low
			-- nWR and nRD are short impluse input signals, not just a signal line 

	);
end component;

component UDP is
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
end component;

component TCP is
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
end component;

component collector is
    Port ( CLK : in  STD_LOGIC;
           nRST : in  STD_LOGIC;
           TXDU : out  STD_LOGIC_VECTOR (7 downto 0);
           TXEN : out  STD_LOGIC;
           TXDC1 : in  STD_LOGIC_VECTOR (7 downto 0);
           TXDC2 : in  STD_LOGIC_VECTOR (7 downto 0);
           TXDV1 : in  STD_LOGIC;
           TXDV2 : in  STD_LOGIC;
           SEL : out  STD_LOGIC;
			  RdU : in STD_LOGIC;
           RdC1 : out  STD_LOGIC;
           RdC2 : out  STD_LOGIC);
end component;

component dispatcher is
    Port ( CLK : in  STD_LOGIC;
           nRST : in  STD_LOGIC;
           RXDU : in  STD_LOGIC_VECTOR (7 downto 0);
           WrU : in  STD_LOGIC;
           RXDC1 : out  STD_LOGIC_VECTOR (7 downto 0);
           RXDC2 : out  STD_LOGIC_VECTOR (7 downto 0);
           WrC1 : out  STD_LOGIC;
           WrC2 : out  STD_LOGIC;
           SEL : in  STD_LOGIC);
end component;

component mii_interface is 
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
end component;

signal Inter_CLK: std_logic;
signal Inter_nRST: std_logic;
signal TXAUD: std_logic_vector (7 downto 0);
signal TXAUDV: std_logic;
signal RXUAD: std_logic_vector (7 downto 0);
signal RXUADV: std_logic;
signal RdUA: std_logic;
signal WrUA: std_logic;
signal TXUCEN: std_logic;
signal TXUCD: std_logic_vector (7 downto 0);
signal RXDUD: std_logic_vector (7 downto 0);
signal RdCU: std_logic;
signal TXCID: std_logic_vector (7 downto 0);
signal TXCIDEN: std_logic;
signal TXTCD: std_logic_vector (7 downto 0);
signal TXTCDV: std_logic;
signal TXUCDV: std_logic;
signal TXCISEL: std_logic;
signal RdIC: std_logic;
signal RdCT: std_logic;
signal RXIDD: std_logic_vector (7 downto 0);
signal WrID: std_logic;
signal RXDTD: std_logic_vector (7 downto 0);
signal WrDT: std_logic;
signal WrDU: std_logic;
signal RXIDSEL: std_logic;
signal TXDIDV: std_logic;
signal TXICDEN: std_logic;
signal TXDID: std_logic_vector (7 downto 0);
signal RXDID: std_logic_vector (7 downto 0);
signal RdCI: std_logic;
signal WrDI: std_logic;
signal TXACEN: std_logic;
signal TXACD: std_logic_vector (7 downto 0);
signal RXDAD: std_logic_vector (7 downto 0);
signal RdCA: std_logic;
signal WrDA: std_logic;
signal TXCMD: std_logic_vector (7 downto 0);
signal TXCMDEN: std_logic;
signal TXCMSEL: std_logic;
signal RdMC: std_logic;
signal RXMDD: std_logic_vector (7 downto 0);
signal WrMD: std_logic;
signal RXMDSEL: std_logic;
signal TXMMDEN: std_logic;
signal TXMMD: std_logic_vector (7 downto 0);
signal RXMMD: std_logic_vector (7 downto 0);
signal MDIO_Busy: std_logic;
signal MDIO_nWR: std_logic;
signal MDIO_nRD: std_logic;
signal RdMM: std_logic;
signal WrMM: std_logic;
signal Inter_CLK_MDC: std_logic;
signal Inter_data_MDIO: std_logic;
signal Inter_TXCLK: std_logic;
signal Inter_RXCLK: std_logic;
signal TXMPDEN: std_logic;
signal RXPMDV: std_logic;
signal TXMPD: std_logic_vector (3 downto 0);
signal RXPMD: std_logic_vector (3 downto 0);
signal TXICD: std_logic_vector (7 downto 0);
signal TXICDV: std_logic;
signal TXACDV: std_logic;
signal TXCMDV: std_logic;
signal TXAAD: std_logic_vector (7 downto 0); -- for testing only, remove after deciding the client
signal Inter_TXIP: std_logic_vector (31 downto 0);
signal Inter_TXIPEN: std_logic;
signal TXTCDEN: std_logic;
signal TXUCDEN: std_logic;
signal TXACDEN: std_logic;
signal TXAUDEN: std_logic;
signal TXAADEN: std_logic; -- for testing only, remove after deciding the client
signal TXATD: std_logic_vector (7 downto 0);
signal RXTAD: std_logic_vector (7 downto 0);
signal TXATDEN: std_logic;
signal RdTA: std_logic;
signal WrTA: std_logic;

begin

TCP_module: TCP
port map(
				CLK => Inter_CLK,
				nRST => Inter_nRST,
				TXDV => TXATDEN,
				TXEN => TXTCDEN,
				TXDC => TXATD,
				TXDU => TXTCD,
				RXDC => RXTAD,
				RXDU => RXDTD,
				RdC => RdTA,
				WrC => WrTA,
				RdU => RdCT,
				WrU => WrDT
);


UDP_module: UDP
port map(
				CLK => Inter_CLK,
				nRST => Inter_nRST,
				TXDV => TXAUDEN,
				TXEN => TXUCDEN,
				TXDC => TXAUD,
				TXDU => TXUCD,
				RXDC => RXUAD,
				RXDU => RXDUD,
				RdC => RdUA,
				WrC => WrUA,
				RdU => RdCU,
				WrU => WrDU
);

IP_collector: collector
port map(
			  CLK => Inter_CLK,
           nRST => Inter_nRST,
           TXDU => TXCID,
           TXEN => TXCIDEN,
           TXDC1 => TXTCD,
           TXDC2 => TXUCD,
           TXDV1 => TXTCDEN,
           TXDV2 => TXUCDEN,
           SEL => TXCISEL,
			  RdU => RdIC,
           RdC1 => RdCT,
           RdC2 => RdCU
);

IP_dispatcher: dispatcher
port map(
			  CLK => Inter_CLK,
           nRST => Inter_nRST,
           RXDU => RXIDD,
			  WrU => WrID,
			  RXDC1 => RXDTD,
			  RXDC2 => RXDUD,
			  WrC1 => WrDT,
			  WrC2 => WrDU,
			  SEL => RXIDSEL
);


-- TXER, RXIP, RXIPV not connected
IP_module: IP
port map( 
			  CLK => Inter_CLK,
           nRST => Inter_nRST,
			  TXDV => TXCIDEN,
			  TXEN => TXICDEN,
			  TXDC => TXCID,
			  TXDU => TXICD,
			  RXDC => RXIDD,
			  RXDU => RXDID,
			  TXIP => Inter_TXIP,
			  TXIPEN => Inter_TXIPEN,
			  RdC => RdIC,
			  WrC => WrID,
			  RdU => RdCI,
			  WrU => WrDI,
			  SELT => TXCISEL,
			  SELR => RXIDSEL
);

-- TXDV, TXDC, RXDC, RdC, WrC not connected
ARP_module: ARP
port map( 
			  CLK => Inter_CLK,
			  nRST => Inter_nRST,
			  TXEN => TXACDEN,
			  TXDU => TXACD,
			  RXDU => RXDAD,
			  TXDV => TXAADEN,
			  TXDC => TXAAD,
			  RdU => RdCA,
			  WrU => WrDA
);


MAC_collector: collector
port map(
			  CLK => Inter_CLK,
           nRST => Inter_nRST,
           TXDU => TXCMD,
           TXEN => TXCMDEN,
           TXDC1 => TXICD,
           TXDC2 => TXACD,
           TXDV1 => TXICDEN,
           TXDV2 => TXACDEN,
           SEL => TXCMSEL,
			  RdU => RdMC,
           RdC1 => RdCI,
           RdC2 => RdCA
);


MAC_dispatcher: dispatcher
port map(
			  CLK => Inter_CLK,
           nRST => Inter_nRST,
           RXDU => RXMDD,
			  WrU => WrMD,
			  RXDC1 => RXDID,
			  RXDC2 => RXDAD,
			  WrC1 => WrDI,
			  WrC2 => WrDA,
			  SEL => RXMDSEL
);

-- RXER not connected
MAC_module: MAC
port map( 
			  CLK => Inter_CLK,
			  nRST => Inter_nRST,
			  TXDV => TXCMDEN,
			  TXEN => TXMMDEN,
			  TXDC => TXCMD,
			  TXDU => TXMMD,
			  RXDC => RXMDD,
			  RXDU => RXMMD,
			  MDIO_Busy => MDIO_Busy,
			  MDIO_nWR => MDIO_nWR,
			  MDIO_nRD => MDIO_nRD,
			  RdC => RdMC,
			  WrC => WrMD,
			  RdU => RdMM,
			  WrU => WrMM,
			  SELT => TXCMSEL,
			  SELR => RXMDSEL
);

MDIO: MDIO_interface
port map(
			  CLK => Inter_CLK,
			  nRST => Inter_nRST,
			  CLK_MDC => Inter_CLK_MDC,
			  data_MDIO => Inter_data_MDIO,
			  busy => MDIO_Busy,
			  nWR => MDIO_nWR,
			  nRD => MDIO_nRD
);
	
	
MII: mii_interface 
port map(
			  CLK => Inter_CLK,
			  nRST => Inter_nRST,
			  TXCLK => Inter_TXCLK,
			  RXCLK => Inter_RXCLK,
			  TXDV => TXMMDEN,
			  TXEN => TXMPDEN,
			  RXDV => RXPMDV,
			  TX_in => TXMMD,
			  TXD => TXMPD,
			  RXD => RXPMD,
			  RX_out => RXMMD,
			  WR => WrMM,
			  RD => RdMM
);

Inter_CLK <= CLK;
Inter_nRST <= nRST;
TXAUD <= TXDUDP;
TXAUDEN <= TXDVUDP;
TXATD <= TXDTCP;
TXATDEN <= TXDVTCP;
TXDPHY <= TXMPD;
TXEN <= TXMPDEN;
RXPMD <= RXDPHY;
RXPMDV <= RXDVPHY;
RdUDP <= RdUA;
WrUDP <= WrUA;
RdTCP <= RdTA;
WrTCP <= WrTA;
Inter_TXCLK <= TXCLK;
Inter_RXCLK <= RXCLK;
CLK_MDC <= Inter_CLK_MDC;
data_MDIO <= Inter_data_MDIO;
Inter_TXIP <= TXIP;
Inter_TXIPEN <= TXIPEN;
RXDTCP <= RXTAD;
RXDUDP <= RXUAD;

-- testing only, remove after proper connection
TXAAD <= X"00";
TXAADEN <= '0';

end Behavioral;

