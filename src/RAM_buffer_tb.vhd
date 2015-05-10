--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:15:07 05/09/2015
-- Design Name:   
-- Module Name:   E:/Github/TCP_full_stack/src//RAM_buffer_tb.vhd
-- Project Name:  project_full_stack
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RAM_buffer
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
 
ENTITY RAM_buffer_tb IS
END RAM_buffer_tb;
 
ARCHITECTURE behavior OF RAM_buffer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RAM_buffer
    PORT(
         nRST : IN  std_logic;
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         DIN : IN  std_logic_vector(15 downto 0);
         DOUT : OUT  std_logic_vector(15 downto 0);
         PUSH : IN  std_logic;
         POP : IN  std_logic;
         COUNT : OUT  std_logic_vector(9 downto 0);
         EMPTY : OUT  std_logic;
         FULL : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nRST : std_logic := '0';
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal DIN : std_logic_vector(15 downto 0) := (others => '0');
   signal PUSH : std_logic := '0';
   signal POP : std_logic := '0';

 	--Outputs
   signal DOUT : std_logic_vector(15 downto 0);
   signal COUNT : std_logic_vector(9 downto 0);
   signal EMPTY : std_logic;
   signal FULL : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAM_buffer PORT MAP (
          nRST => nRST,
          CLK => CLK,
          RESET => RESET,
          DIN => DIN,
          DOUT => DOUT,
          PUSH => PUSH,
          POP => POP,
          COUNT => COUNT,
          EMPTY => EMPTY,
          FULL => FULL
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
      wait for 100 ns;	
		nRST <= '1';
		
		PUSH <= '1';
		POP <= '0';
		DIN <= std_logic_vector(to_unsigned(1, DIN'length));		
		wait for CLK_period;
		assert(DOUT = std_logic_vector(to_unsigned(1, DIN'length))) report "FAILURE";
		
		PUSH <= '0';
		POP <= '1';		
		wait for CLK_period;		
		
		
		PUSH <= '1';
		POP <= '0';
		DIN <= std_logic_vector(to_unsigned(2, DIN'length));		
		wait for CLK_period;
		
		PUSH <= '1';
		POP <= '0';
		DIN <= std_logic_vector(to_unsigned(3, DIN'length));		
		wait for CLK_period;
		assert(DOUT = std_logic_vector(to_unsigned(2, DIN'length))) report "FAILURE";

		PUSH <= '0';
		POP <= '1';		
		wait for CLK_period;
		assert(DOUT = std_logic_vector(to_unsigned(3, DIN'length))) report "FAILURE";
		
		
		PUSH <= '0';
		POP <= '1';		
		wait for CLK_period;
		

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
