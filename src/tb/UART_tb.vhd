--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:29:23 04/19/2015
-- Design Name:   
-- Module Name:   E:/Github/TCP_full_stack/src/tb//UART_tb.vhd
-- Project Name:  project_full_stack
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY UART_tb IS
END UART_tb;
 
ARCHITECTURE behavior OF UART_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
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
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal RX_serial : std_logic := '0';
   signal TXD : std_logic_vector(7 downto 0) := (others => '0');
   signal TXDV : std_logic := '0';

 	--Outputs
   signal TX_serial : std_logic;
   signal RXD : std_logic_vector(7 downto 0);
   signal RXDV : std_logic;
	signal WR : std_logic;
	signal RD : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART PORT MAP (
          CLK => CLK,
          nRST => nRST,
          RX_serial => RX_serial,
          TX_serial => TX_serial,
          RXD => RXD,
          TXD => TXD,
          RXDV => RXDV,
          TXDV => TXDV,
			 WR => WR,
			 RD => RD
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
	RX_serial <= TX_serial after 1 ns;
   -- Stimulus process
   rx_proc: process
		-- Note that LSB is transmitted first

		type char_array is array(integer range <>) of std_logic_vector(7 downto 0);
		
		-- Input data
		constant vector_to_rx : char_array(0 to 3) := (x"FF", x"00", x"55", x"AA");
		
		-- Period: 1s / 115200 ~ 8680.55 ns
		constant uart_period :time := 8680.55 ns;
   begin		
      nRST <= '0';
      wait for 100 ns;	
		nRST <= '1';

      wait;
   end process;
	
	tx_proc: process
		type char_array is array(integer range <>) of std_logic_vector(7 downto 0);
		
		-- Input data
		constant vector_to_tx : char_array(0 to 3) := (x"FF", x"00", x"55", x"AA");
		
		-- Period: 1s / 115200 ~ 8680.55 ns
		constant uart_period :time := 8680.55 ns;
	begin
		TXDV <= '1';
		TXD <= vector_to_tx(0);
		wait until (rising_edge(CLK) and RD = '1');
		TXD <= vector_to_tx(1);
		wait until (rising_edge(CLK) and RD = '1');
		TXD <= vector_to_tx(2);
		wait until (rising_edge(CLK) and RD = '1');
		TXD <= vector_to_tx(3);
		wait until (rising_edge(CLK) and RD = '1');
		TXDV <= '0';
		
		wait;
	end process;

END;
