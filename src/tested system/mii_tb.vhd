--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:58:07 06/01/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/MII_VHDL/mii_tb.vhd
-- Project Name:  TCPIP_MII
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mii_interface
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
 
ENTITY mii_tb IS
END mii_tb;
 
ARCHITECTURE behavior OF mii_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mii_interface
    PORT(
         CLK : IN  std_logic;
         TXCLK : IN  std_logic;
         RXCLK : IN  std_logic;
         nRST : IN  std_logic;
         TXDV : IN  std_logic;
         TXEN : OUT  std_logic;
         RXDV : IN  std_logic;
         TX_in : IN  std_logic_vector(7 downto 0);
         TXD : OUT  std_logic_vector(3 downto 0);
         RXD : IN  std_logic_vector(3 downto 0);
         RX_out : OUT  std_logic_vector(7 downto 0);
         WR : OUT  std_logic;
         RD : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal TXCLK : std_logic := '0';
   signal RXCLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal TXDV : std_logic := '0';
   signal RXDV : std_logic := '0';
   signal TX_in : std_logic_vector(7 downto 0) := (others => '0');
   signal RXD : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal TXEN : std_logic;
   signal TXD : std_logic_vector(3 downto 0);
   signal RX_out : std_logic_vector(7 downto 0);
   signal WR : std_logic;
   signal RD : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
   constant TXCLK_period : time := 400 ns;
   constant RXCLK_period : time := 400 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mii_interface PORT MAP (
          CLK => CLK,
          TXCLK => TXCLK,
          RXCLK => RXCLK,
          nRST => nRST,
          TXDV => TXDV,
          TXEN => TXEN,
          RXDV => RXDV,
          TX_in => TX_in,
          TXD => TXD,
          RXD => RXD,
          RX_out => RX_out,
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
 
   TXCLK_process :process
   begin
		TXCLK <= '0';
		wait for TXCLK_period/2;
		TXCLK <= '1';
		wait for TXCLK_period/2;
   end process;
 
   RXCLK_process :process
   begin
		RXCLK <= '0';
		wait for RXCLK_period/2;
		RXCLK <= '1';
		wait for RXCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;
		
		nRST <= '0';
		
		wait for CLK_period;
		
		nRST <= '1';
		
		wait for CLK_period;
		
		
		TX_in <= X"AB";
		RXD <= X"C";
		
		TXDV <= '1';
		RXDV <= '1';


      wait;
   end process;

END;
