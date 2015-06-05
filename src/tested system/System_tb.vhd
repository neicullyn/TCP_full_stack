--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:12:39 06/04/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/SysTb/System_tb.vhd
-- Project Name:  SysTb
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: System
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
USE ieee.numeric_std.ALL;
 
ENTITY System_tb IS
END System_tb;
 
ARCHITECTURE behavior OF System_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT System
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         TXDUDP : IN  std_logic_vector(7 downto 0);
         TXDVUDP : IN  std_logic;
			TXDTCP : IN  std_logic_vector(7 downto 0);
         TXDVTCP : IN  std_logic;
         TXDPHY : OUT  std_logic_vector(3 downto 0);
         TXEN : OUT  std_logic;
         RXDPHY : IN  std_logic_vector(3 downto 0);
         RXDVPHY : IN  std_logic;
			RXDTCP : OUT std_logic_vector(7 downto 0);
			RXDUDP : OUT std_logic_vector(7 downto 0);
         RdUDP : OUT  std_logic;
         WrUDP : OUT  std_logic;
         RdTCP : OUT  std_logic;
         WrTCP : OUT  std_logic;
			TXCLK : IN  std_logic;
         RXCLK : IN  std_logic;
         CLK_MDC : OUT  std_logic;
         data_MDIO : INOUT  std_logic;
         TXIP : IN  std_logic_vector(31 downto 0);
         TXIPEN : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal TXDUDP : std_logic_vector(7 downto 0) := (others => '0');
   signal TXDVUDP : std_logic := '0';
   signal TXDTCP : std_logic_vector(7 downto 0) := (others => '0');
   signal TXDVTCP : std_logic := '0';
	signal RXDPHY : std_logic_vector(3 downto 0) := (others => '0');
   signal RXDVPHY : std_logic := '0';
   signal TXCLK : std_logic := '0';
   signal RXCLK : std_logic := '0';
   signal TXIP : std_logic_vector(31 downto 0) := (others => '0');
   signal TXIPEN : std_logic := '0';

	--BiDirs
   signal data_MDIO : std_logic;

 	--Outputs
   signal TXDPHY : std_logic_vector(3 downto 0);
   signal TXEN : std_logic;
   signal RdUDP : std_logic;
   signal WrUDP : std_logic;
   signal RdTCP : std_logic;
   signal WrTCP : std_logic;
	signal CLK_MDC : std_logic;
	signal RXDTCP : std_logic_vector(7 downto 0);
	signal RXDUDP : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
   constant TXCLK_period : time := 400 ns;
   constant RXCLK_period : time := 400 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: System PORT MAP (
          CLK => CLK,
          nRST => nRST,
          TXDUDP => TXDUDP,
          TXDVUDP => TXDVUDP,
          TXDTCP => TXDTCP,
          TXDVTCP => TXDVTCP,
			 TXDPHY => TXDPHY,
          TXEN => TXEN,
          RXDPHY => RXDPHY,
          RXDVPHY => RXDVPHY,
			 RXDTCP => RXDTCP,
			 RXDUDP => RXDUDP,
          RdUDP => RdUDP,
          WrUDP => WrUDP,
          RdTCP => RdTCP,
          WrTCP => WrTCP,
			 TXCLK => TXCLK,
          RXCLK => RXCLK,
          CLK_MDC => CLK_MDC,
          data_MDIO => data_MDIO,
          TXIP => TXIP,
          TXIPEN => TXIPEN
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
		
		TXIP <= X"E0000001";
		TXIPEN <= '1';
		
		wait for CLK_period * 5;
		
		TXIPEN <= '0';
		
		TXDVUDP <= '1';
		
		RXDVPHY <= '1';
		
	
		-- TX text
		for i in 0 to 100 loop
			wait until (RdUDP = '1' or RXCLK = '1');
			if (RdUDP = '1') then
				TXDUDP <= std_logic_vector(to_unsigned(i,8));
			end if;
			if (RXCLK = '1') then
				RXDPHY <= std_logic_vector(to_unsigned(i,8));
			end if;
		end loop;
		
      wait;
   end process;

END;
