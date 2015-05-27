--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   04:43:25 05/27/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/dispatcher/dispatcher_tb.vhd
-- Project Name:  dispatcher
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dispatcher
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
 
ENTITY dispatcher_tb IS
END dispatcher_tb;
 
ARCHITECTURE behavior OF dispatcher_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dispatcher
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         RXDU : IN  std_logic_vector(7 downto 0);
         WrU : IN  std_logic;
         RXDC1 : OUT  std_logic_vector(7 downto 0);
         RXDC2 : OUT  std_logic_vector(7 downto 0);
         WrC1 : OUT  std_logic;
         WrC2 : OUT  std_logic;
         SEL : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal RXDU : std_logic_vector(7 downto 0) := (others => '0');
   signal WrU : std_logic := '0';
   signal SEL : std_logic := '0';

 	--Outputs
   signal RXDC1 : std_logic_vector(7 downto 0);
   signal RXDC2 : std_logic_vector(7 downto 0);
   signal WrC1 : std_logic;
   signal WrC2 : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dispatcher PORT MAP (
          CLK => CLK,
          nRST => nRST,
          RXDU => RXDU,
          WrU => WrU,
          RXDC1 => RXDC1,
          RXDC2 => RXDC2,
          WrC1 => WrC1,
          WrC2 => WrC2,
          SEL => SEL
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
		
		RXDU <= X"AA";
		
		SEL <= '0';
		
		WrU <= '1';
		
		wait for CLK_period;
		
		WrU <= '0';
		
		wait for CLK_period * 10;
		
		SEL <= '1';
		WrU <= '1';
		wait for CLK_period;
		
		WrU <= '0';
		
		wait for CLK_period * 10;
		
		
		RXDU <= X"BB";
		
		SEL <= '0';
		
		WrU <= '1';
		
		wait for CLK_period;
		
		WrU <= '0';
		
		wait for CLK_period * 10;
		
		SEL <= '1';
		WrU <= '1';
		wait for CLK_period;
		
		WrU <= '0';
		
		wait for CLK_period * 10;
		
		
		
      wait;
   end process;

END;
