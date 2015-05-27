--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:08:34 05/27/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/collector/collector_tb.vhd
-- Project Name:  collector
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: collector
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
 
ENTITY collector_tb IS
END collector_tb;
 
ARCHITECTURE behavior OF collector_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT collector
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         TXDU : OUT  std_logic_vector(7 downto 0);
         TXEN : OUT  std_logic;
         TXDC1 : IN  std_logic_vector(7 downto 0);
         TXDC2 : IN  std_logic_vector(7 downto 0);
         TXDV1 : IN  std_logic;
         TXDV2 : IN  std_logic;
         SEL : OUT  std_logic;
         RdU : IN  std_logic;
         RdC1 : OUT  std_logic;
         RdC2 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal TXDC1 : std_logic_vector(7 downto 0) := (others => '0');
   signal TXDC2 : std_logic_vector(7 downto 0) := (others => '0');
   signal TXDV1 : std_logic := '0';
   signal TXDV2 : std_logic := '0';
   signal RdU : std_logic := '0';

 	--Outputs
   signal TXDU : std_logic_vector(7 downto 0);
   signal TXEN : std_logic;
   signal SEL : std_logic;
   signal RdC1 : std_logic;
   signal RdC2 : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: collector PORT MAP (
          CLK => CLK,
          nRST => nRST,
          TXDU => TXDU,
          TXEN => TXEN,
          TXDC1 => TXDC1,
          TXDC2 => TXDC2,
          TXDV1 => TXDV1,
          TXDV2 => TXDV2,
          SEL => SEL,
          RdU => RdU,
          RdC1 => RdC1,
          RdC2 => RdC2
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
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
		
		TXDC1 <= X"AA";
		TXDC2 <= X"BB";
		
		TXDV1 <= '1';
		TXDV2 <= '1';
		
		wait for CLK_period;
		
		RdU <= '1';
		
		wait for CLK_period;
		
		RdU <= '0';
		
		wait for CLK_period * 10;
		
		TXDV1 <= '0';
		
		wait for CLK_period;
		RdU <= '1';
		wait for CLK_period;
		
		RdU <= '0';
		
		wait for CLK_period;
		RdU <= '1';
		wait for CLK_period;
		
		RdU <= '0';

		
      wait;
   end process;

END;
