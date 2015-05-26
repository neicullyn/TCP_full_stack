--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:51:41 05/25/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/MDIO_interface/mdio.vhd
-- Project Name:  MDIO_interface
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MDIO_interface
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
 
ENTITY mdio IS
END mdio;
 
ARCHITECTURE behavior OF mdio IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
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
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '1';
   signal nWR : std_logic := '1';
   signal nRD : std_logic := '1';

	--BiDirs
   signal data_MDIO : std_logic;

 	--Outputs
   signal CLK_MDC : std_logic;
   signal busy : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
   -- constant CLK_MDC_period : time := 10 ns;
	constant CLK_MDC_period : time := 400 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MDIO_interface PORT MAP (
          CLK => CLK,
          nRST => nRST,
          CLK_MDC => CLK_MDC,
          data_MDIO => data_MDIO,
          busy => busy,
          nWR => nWR,
          nRD => nRD
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
		
		nRST <= '0';
		
		wait for CLK_MDC_period;
		
		nRST <= '1';
		
		wait for CLK_MDC_period;
		
      nWR <= '0';
		
		wait for CLK_MDC_period;
		
		nWR <= '1';
		
		wait for CLK_MDC_period * 200;
		
		nRD <= '0';
		
		wait for CLK_MDC_period;
		
		nRD <= '1';
		
		wait for CLK_MDC_period * 200;
      wait;
   end process;

END;
