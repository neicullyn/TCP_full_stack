--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:30:23 05/27/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/MAC/CRC_tb.vhd
-- Project Name:  MAC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CRC
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
 
ENTITY CRC_tb IS
END CRC_tb;
 
ARCHITECTURE behavior OF CRC_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CRC
    PORT(
         CLOCK : IN  std_logic;
         RESET : IN  std_logic;
         DATA : IN  std_logic_vector(7 downto 0);
         LOAD_INIT : IN  std_logic;
         CALC : IN  std_logic;
         D_VALID : IN  std_logic;
         CRC : OUT  std_logic_vector(7 downto 0);
         CRC_REG : OUT  std_logic_vector(31 downto 0);
         CRC_VALID : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal DATA : std_logic_vector(7 downto 0) := (others => '0');
   signal LOAD_INIT : std_logic := '0';
   signal CALC : std_logic := '0';
   signal D_VALID : std_logic := '0';

 	--Outputs
   signal TCRC : std_logic_vector(7 downto 0);
	signal CRC_REG : std_logic_vector(31 downto 0);
   signal CRC_VALID : std_logic;

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CRC 
	PORT MAP (
          CLOCK => CLOCK,
          RESET => RESET,
          DATA => DATA,
          LOAD_INIT => LOAD_INIT,
          CALC => CALC,
          D_VALID => D_VALID,
          CRC => TCRC,
          CRC_REG => CRC_REG,
          CRC_VALID => CRC_VALID
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLOCK_period*10;
		
		RESET <= '1';
		
		wait for CLOCK_period;
		
		RESET <= '0';
		
		wait for CLOCK_period;
		
		LOAD_INIT <= '1';
		
		wait for CLOCK_period;
		
		LOAD_INIT <= '0';
		
		wait for CLOCK_period;
		
		DATA <= X"11";
		
		D_VALID <= '1';
		CALC <= '1';
		
		wait for CLOCK_period;
		
		DATA <= X"7F";
		wait for CLOCK_period;
		
		DATA <= X"CF";
		
		wait for CLOCK_period;
		
		DATA <= X"B2";
		
		wait for CLOCK_period;
		
		DATA <= X"B8";
		
		wait for CLOCK_period;
		
		CALC <= '0';
		
		wait for CLOCK_period * 4;
		
		
		
		
		DATA <= CRC_REG(31 downto 24);
		
		wait for CLOCK_period;
		
		DATA <= CRC_REG(23 downto 16);
		
		wait for CLOCK_period;
		
		DATA <= CRC_REG(15 downto 8);
		
		wait for CLOCK_period;
		
		DATA <= CRC_REG(7 downto 0);
		
		wait for CLOCK_period;
      -- insert stimulus here 

      wait;
   end process;

END;
