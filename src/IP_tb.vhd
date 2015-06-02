--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:56:43 06/01/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/IP/IP_tb.vhd
-- Project Name:  IP
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IP
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
 
ENTITY IP_tb IS
END IP_tb;
 
ARCHITECTURE behavior OF IP_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IP
    PORT(
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         TXDV : IN  std_logic;
         TXEN : OUT  std_logic;
         TXDC : IN  std_logic_vector(7 downto 0);
         TXDU : OUT  std_logic_vector(7 downto 0);
         RXDC : OUT  std_logic_vector(7 downto 0);
         RXDU : IN  std_logic_vector(7 downto 0);
         RXER : OUT  std_logic;
         RdC : OUT  std_logic;
         WrC : OUT  std_logic;
         RdU : IN  std_logic;
         WrU : IN  std_logic;
         SELT : IN  std_logic;
         SELR : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal TXDV : std_logic := '0';
   signal TXDC : std_logic_vector(7 downto 0) := (others => '0');
   signal RXDU : std_logic_vector(7 downto 0) := (others => '0');
   signal RdU : std_logic := '0';
   signal WrU : std_logic := '0';
   signal SELT : std_logic := '0';

 	--Outputs
   signal TXEN : std_logic;
   signal TXDU : std_logic_vector(7 downto 0);
   signal RXDC : std_logic_vector(7 downto 0);
   signal RXER : std_logic;
   signal RdC : std_logic;
   signal WrC : std_logic;
   signal SELR : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IP PORT MAP (
          CLK => CLK,
          nRST => nRST,
          TXDV => TXDV,
          TXEN => TXEN,
          TXDC => TXDC,
          TXDU => TXDU,
          RXDC => RXDC,
          RXDU => RXDU,
          RXER => RXER,
          RdC => RdC,
          WrC => WrC,
          RdU => RdU,
          WrU => WrU,
          SELT => SELT,
          SELR => SELR
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
		SELT <= '0';
		TXDV <= '1';
		TXDC <= X"AB";
		
		RXDU <= X"CD";
		
		wait for CLK_period;
		
		for i in 0 to 1000 loop	
			RdU <= '1';
			WrU <= '1';		
			wait for CLK_period;
			RdU <= '0';
			WrU <= '0';
			wait for CLK_period * 39;
		end loop;
      
		wait;
   end process;

END;
