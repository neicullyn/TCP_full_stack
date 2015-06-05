--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:09:06 05/31/2015
-- Design Name:   
-- Module Name:   C:/Users/Lydia/Desktop/Caltech Spring2015/EE119C/topics/TCP/CHCKSUM/CHECKSUM_tb.vhd
-- Project Name:  CHCKSUM
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CHECKSUM
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
 
ENTITY CHECKSUM_tb IS
END CHECKSUM_tb;
 
ARCHITECTURE behavior OF CHECKSUM_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CHECKSUM
    PORT(
         CLK : IN  std_logic;
         DATA : IN  std_logic_vector(7 downto 0);
         nRST : IN  std_logic;
         INIT : IN  std_logic;
         D_VALID : IN  std_logic;
         CALC : IN  std_logic;
         REQ : IN  std_logic;
         SELB : IN  std_logic;
         CHKSUM : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal DATA : std_logic_vector(7 downto 0) := (others => '0');
   signal nRST : std_logic := '0';
   signal INIT : std_logic := '0';
   signal D_VALID : std_logic := '0';
   signal CALC : std_logic := '0';
   signal REQ : std_logic := '0';
   signal SELB : std_logic := '0';

 	--Outputs
   signal CHKSUM : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
	
	
	-- Testing constants
	type Tarray is array (9 downto 0) of std_logic_vector(15 downto 0);
	constant TDATA: Tarray := (X"4500", X"0030", X"4422", X"4000", X"8006", X"442E", X"8c7c", X"19ac", X"ae24", X"1e2b");

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CHECKSUM PORT MAP (
          CLK => CLK,
          DATA => DATA,
          nRST => nRST,
          INIT => INIT,
          D_VALID => D_VALID,
          CALC => CALC,
          REQ => REQ,
          SELB => SELB,
          CHKSUM => CHKSUM
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
		
		INIT <= '1';
		
		wait for CLK_period;
		
		INIT <= '0';
		
		wait for CLK_period;
		
		for i in 0 to 9 loop
			DATA <= TDATA(i)(15 downto 8);
			D_VALID <= '1';
			SELB <= '0';
			CALC <= '0';
			wait for CLK_period;
			DATA <= TDATA(i)(7 downto 0);
			D_VALID <= '1';
			SELB <= '1';
			CALC <= '1';
			wait for CLK_period;			
      end loop;
		
		CALC <= '0';
		D_VALID <= '0';
		REQ <= '1';
		
		SELB <= '0';
		
		wait for CLK_period * 10;
		
		SELB <= '1';
		
		wait for CLK_period * 10;
		
		REQ <= '0';
		
		wait;
   end process;

END;
