--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:10:33 05/02/2015
-- Design Name:   
-- Module Name:   E:/Github/TCP_full_stack/src/tb/Counter_tb.vhd
-- Project Name:  project_full_stack
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Counter
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
 
ENTITY Counter_tb IS
END Counter_tb;
 
ARCHITECTURE behavior OF Counter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Counter
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         EN1 : IN  std_logic;
			EN2 : IN  std_logic;
         COUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal EN : std_logic := '0';

 	--Outputs
   signal COUT : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Counter PORT MAP (
          CLK => CLK,
          nRST => nRST,
          EN1 => EN,
			 EN2 => EN,
          COUT => COUT
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
		nRST <= '0';
		EN <= '0';
      wait for 100 ns;	
		nRST <= '1';

      wait for CLK_period*10;
		
		EN <= '1';
		wait for CLK_period * 5;
		EN <= '0';
		wait for CLK_period * 1;
		EN <= '1';
		wait for CLK_period * 1;
		EN <= '0';
		wait for CLK_period * 1;
		EN <= '1';
		wait for CLK_period * 1;
		EN <= '0';
		wait for CLK_period * 1;
		EN <= '1';
		wait for CLK_period * 1;
		EN <= '0';
		wait for CLK_period * 1;
		EN <= '1';
		wait for CLK_period * 1;
		EN <= '0';
		wait for CLK_period * 1;
		EN <= '1';
		wait for CLK_period * 1;
		EN <= '0';
		wait for CLK_period * 1;
		EN <= '1';
		wait for CLK_period * 1;
		

      -- insert stimulus here 

      wait;
   end process;

END;
