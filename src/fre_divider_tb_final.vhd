--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:41:08 05/08/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/MDIO_interface/fre_divider_tb.vhd
-- Project Name:  MDIO_interface
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fre_divider
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
 
ENTITY fre_divider_tb IS
END fre_divider_tb;
 
ARCHITECTURE behavior OF fre_divider_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fre_divider
    PORT(
         CLK : IN  std_logic;
         CLK_MDC : OUT  std_logic;
         nRST : IN  std_logic;
         --EN1 : IN  std_logic;
         --EN2 : IN  std_logic
			CLK_5M : OUT std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal EN1 : std_logic := '1';
   signal EN2 : std_logic := '1';
	signal MDC_in: std_logic;
	signal MDC_out: std_logic;
	signal CLK_5M: std_logic;

 	--Outputs
   signal CLK_MDC : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns; -- 10ns is actually 100MHz..
   constant CLK_MDC_period : time := 400 ns; -- CLK_MDC should be 2.5MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fre_divider PORT MAP (
          CLK => CLK,
          CLK_MDC => CLK_MDC,
          nRST => nRST,
          CLK_5M => CLK_5M
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
--   CLK_MDC_process :process
--  begin
--		CLK_MDC <= '0';
--		wait for CLK_MDC_period/2;
--		CLK_MDC <= '1';
--		wait for CLK_MDC_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      nRST <= '0';				
      wait for CLK_period*10;
		nRST <= '1';
      wait for CLK_period*400;

      -- insert stimulus here 

      wait;
   end process;

END;
