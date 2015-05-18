--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:33:16 05/08/2015
-- Design Name:   
-- Module Name:   E:/Github/TCP_full_stack/src/tb/RAM_Controller_tb.vhd
-- Project Name:  project_full_stack
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RAM_Controller
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
 
ENTITY RAM_Controller_tb IS
END RAM_Controller_tb;
 
ARCHITECTURE behavior OF RAM_Controller_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RAM_Controller
    PORT(
         ADDR : OUT  std_logic_vector(22 downto 0);
         DATA : INOUT  std_logic_vector(15 downto 0);
         CLK_out : OUT  std_logic;
         nCE : OUT  std_logic;
         nWE : OUT  std_logic;
         nOE : OUT  std_logic;
         nADV : OUT  std_logic;
         CRE : OUT  std_logic;
         nLB : OUT  std_logic;
         nUB : OUT  std_logic;
         WAIT_in : IN  std_logic;
         CLK : IN  std_logic;
         nRST : IN  std_logic;
         ADDR_base : IN  std_logic_vector(22 downto 0);
         N_WORDS : IN  std_logic_vector(9 downto 0);
         DIN : IN  std_logic_vector(15 downto 0);
         DOUT : OUT  std_logic_vector(15 downto 0);
         BUSY : OUT  std_logic;
         WR : IN  std_logic;
         RD : IN  std_logic;
         DINU : OUT  std_logic;
         DOUTV : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal WAIT_in : std_logic := '0';
   signal CLK : std_logic := '0';
   signal nRST : std_logic := '0';
   signal ADDR_base : std_logic_vector(22 downto 0) := (others => '0');
   signal N_WORDS : std_logic_vector(9 downto 0) := (others => '0');
   signal DIN : std_logic_vector(15 downto 0) := (others => '0');
   signal WR : std_logic := '0';
   signal RD : std_logic := '0';

	--BiDirs
   signal DATA : std_logic_vector(15 downto 0);

 	--Outputs
   signal ADDR : std_logic_vector(22 downto 0);
   signal CLK_out : std_logic;
   signal nCE : std_logic;
   signal nWE : std_logic;
   signal nOE : std_logic;
   signal nADV : std_logic;
   signal CRE : std_logic;
   signal nLB : std_logic;
   signal nUB : std_logic;
   signal DOUT : std_logic_vector(15 downto 0);
   signal BUSY : std_logic;
   signal DINU : std_logic;
   signal DOUTV : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
	
	type RAM_STATE_TYPE is (IDLE, BCR, RD_STATE, WR_STATE);
	signal RAM_state : RAM_STATE_TYPE;
	signal RAM_counter : unsigned(3 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAM_Controller PORT MAP (
          ADDR => ADDR,
          DATA => DATA,
          CLK_out => CLK_out,
          nCE => nCE,
          nWE => nWE,
          nOE => nOE,
          nADV => nADV,
          CRE => CRE,
          nLB => nLB,
          nUB => nUB,
          WAIT_in => WAIT_in,
          CLK => CLK,
          nRST => nRST,
          ADDR_base => ADDR_base,
          N_WORDS => N_WORDS,
          DIN => DIN,
          DOUT => DOUT,
          BUSY => BUSY,
          WR => WR,
          RD => RD,
          DINU => DINU,
          DOUTV => DOUTV
        );

 
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
		
		WR <= '0';
		RD <= '0';
      
		wait until BUSY = '0';

      ADDR_base <= (others => '0');
		ADDR_base(7 downto 0) <= x"7D";
		N_WORDS <= std_logic_vector(to_unsigned(4, N_WORDS'length));
		
		WR <= '1';
		RD <= '0';
		
		DIN <= x"0000";
		wait until DINU = '1' and rising_edge(CLK);
		
		ADDR_base(7 downto 0) <= x"00";
		N_WORDS <= std_logic_vector(to_unsigned(0, N_WORDS'length));
		WR <= '0';
		RD <= '0';

		DIN <= x"0002";
		wait until DINU = '1' and rising_edge(CLK);		
		
		DIN <= x"0004";
		wait until DINU = '1' and rising_edge(CLK);		
		
		DIN <= x"0008";	
		
		wait until BUSY = '0';
		
		WR <= '0';
		RD <= '1';
		
		ADDR_base(7 downto 0) <= x"7D";
		N_WORDS <= std_logic_vector(to_unsigned(8, N_WORDS'length));
		
		wait until BUSY = '1';
		
		ADDR_base(7 downto 0) <= x"00";
		N_WORDS <= std_logic_vector(to_unsigned(0, N_WORDS'length));
		
		WR <= '0';
		RD <= '0';
		
		wait until BUSY = '0';
		
      wait;
   end process;
	
	ram_fsm_proc: process(nCE, CLK)
	begin
		if(nCE = '1') then
			RAM_state <= IDLE;
			RAM_counter <= to_unsigned(0, RAM_counter'length);
			WAIT_in <= 'Z';
		elsif (rising_edge(CLK)) then
			if (RAM_state = IDLE) then
				if (CRE = '1') then
					RAM_state <= BCR;
				else
					if(nWE = '1') then
						-- READ
						WAIT_in <= RAM_counter(0);
						RAM_state <= RD_STATE;					
					else
						-- WRITE
						WAIT_in <= RAM_counter(0);
						RAM_state <= WR_STATE;
					end if;
				end if;
			end if;
			
			if (RAM_state = BCR) then
				WAIT_in <= '0';
				if (RAM_counter < 1) then
					RAM_counter <= RAM_counter + 1;
				elsif (RAM_counter = 1) then
					WAIT_in <= '1';
					RAM_counter <= RAM_counter + 1;
				elsif (RAM_counter = 2) then
					WAIT_in <= 'Z';					
				end if;
			end if;
			
			if (RAM_state = RD_STATE) then
				RAM_counter <= RAM_counter + 1;
				WAIT_in <= RAM_counter(1);
			end if;
			
			if (RAM_state = WR_STATE) then
				RAM_counter <= RAM_counter + 1;
				WAIT_in <= RAM_counter(1);
			end if;
			
		end if;
	end process;
	
	ram_output: process(nOE, CLK)
	begin
		if (nOE = '0') then
			DATA <= (others => '0');
			DATA(3 downto 0) <= std_logic_vector(RAM_counter);
		else
			DATA <= (others => 'Z');
		end if;
	end process;

END;
