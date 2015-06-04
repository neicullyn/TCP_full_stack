--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:05:48 06/04/2015
-- Design Name:   
-- Module Name:   E:/Github/TCP_full_stack/src/tcp_trs_task_scheduler_tb.vhd
-- Project Name:  project_full_stack
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: tcp_trs_task_scheduler
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
 
ENTITY tcp_trs_task_scheduler_tb IS
END tcp_trs_task_scheduler_tb;
 
ARCHITECTURE behavior OF tcp_trs_task_scheduler_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT tcp_trs_task_scheduler
    PORT(
         core_dst_addr : IN  std_logic_vector(31 downto 0);
         core_dst_port : IN  std_logic_vector(15 downto 0);
         core_ack_num : IN  std_logic_vector(31 downto 0);
         core_ack : IN  std_logic;
         core_rst : IN  std_logic;
         core_syn : IN  std_logic;
         core_fin : IN  std_logic;
         core_push : IN  std_logic;
		 core_pushing : OUT std_logic;
         app_dst_addr : IN  std_logic_vector(31 downto 0);
         app_dst_port : IN  std_logic_vector(15 downto 0);
         app_ack_num : IN  std_logic_vector(31 downto 0);
         app_en_data : IN  std_logic;
         app_data_addr : IN  std_logic_vector(22 downto 0);
         app_data_len : IN  std_logic_vector(10 downto 0);
         app_push : IN  std_logic;
		 app_pushing : OUT std_logic;
         dst_addr : OUT  std_logic_vector(31 downto 0);
         dst_port : OUT  std_logic_vector(15 downto 0);
         ack_num : OUT  std_logic_vector(31 downto 0);
         data_offset : OUT  std_logic_vector(3 downto 0);
         flags : OUT  std_logic_vector(8 downto 0);
         window_size : OUT  std_logic_vector(15 downto 0);
         urgent_pointer : OUT  std_logic_vector(15 downto 0);
         en_data : OUT  std_logic;
         data_addr : OUT  std_logic_vector(22 downto 0);
         data_len : OUT  std_logic_vector(10 downto 0);
         valid : OUT  std_logic;
         update : IN  std_logic;
         empty : OUT  std_logic;
         nRST : IN  std_logic;
         CLK : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal core_dst_addr : std_logic_vector(31 downto 0) := (others => '0');
   signal core_dst_port : std_logic_vector(15 downto 0) := (others => '0');
   signal core_ack_num : std_logic_vector(31 downto 0) := (others => '0');
   signal core_ack : std_logic := '0';
   signal core_rst : std_logic := '0';
   signal core_syn : std_logic := '0';
   signal core_fin : std_logic := '0';
   signal core_push : std_logic := '0';	
   signal app_dst_addr : std_logic_vector(31 downto 0) := (others => '0');
   signal app_dst_port : std_logic_vector(15 downto 0) := (others => '0');
   signal app_ack_num : std_logic_vector(31 downto 0) := (others => '0');
   signal app_en_data : std_logic := '0';
   signal app_data_addr : std_logic_vector(22 downto 0) := (others => '0');
   signal app_data_len : std_logic_vector(10 downto 0) := (others => '0');
   signal app_push : std_logic := '0';
   signal update : std_logic := '0';
   signal nRST : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
	signal core_pushing : std_logic;
	signal app_pushing : std_logic;
   signal dst_addr : std_logic_vector(31 downto 0);
   signal dst_port : std_logic_vector(15 downto 0);
   signal ack_num : std_logic_vector(31 downto 0);
   signal data_offset : std_logic_vector(3 downto 0);
   signal flags : std_logic_vector(8 downto 0);
   signal window_size : std_logic_vector(15 downto 0);
   signal urgent_pointer : std_logic_vector(15 downto 0);
   signal en_data : std_logic;
   signal data_addr : std_logic_vector(22 downto 0);
   signal data_len : std_logic_vector(10 downto 0);
   signal valid : std_logic;
   signal empty : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: tcp_trs_task_scheduler PORT MAP (
          core_dst_addr => core_dst_addr,
          core_dst_port => core_dst_port,
          core_ack_num => core_ack_num,
          core_ack => core_ack,
          core_rst => core_rst,
          core_syn => core_syn,
          core_fin => core_fin,
          core_push => core_push,
		  core_pushing => core_pushing,
          app_dst_addr => app_dst_addr,
          app_dst_port => app_dst_port,
          app_ack_num => app_ack_num,
          app_en_data => app_en_data,
          app_data_addr => app_data_addr,
          app_data_len => app_data_len,
          app_push => app_push,
		  app_pushing => app_pushing,
          dst_addr => dst_addr,
          dst_port => dst_port,
          ack_num => ack_num,
          data_offset => data_offset,
          flags => flags,
          window_size => window_size,
          urgent_pointer => urgent_pointer,
          en_data => en_data,
          data_addr => data_addr,
          data_len => data_len,
          valid => valid,
          update => update,
          empty => empty,
          nRST => nRST,
          CLK => CLK
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
   stim_proc1: process
   begin		
      -- hold reset state for 100 ns.
		nRST <= '0';
      wait for 100 ns;	
		nRST <= '1';

      wait for CLK_period*10;
	  
      core_dst_addr <= x"12345678";
      core_dst_port <= x"1234";
      core_ack_num <= x"00000001";
      core_ack <= '1';
      core_rst <= '0';
      core_syn <= '1';
      core_fin <= '0';
		
      core_push <= '1';
	  
		wait until core_pushing = '1';

      core_push <= '0';

      wait;
   end process;

   stim_proc2: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;
		
      app_dst_addr <= x"23456789";
      app_dst_port <= x"4321";
      app_ack_num  <= x"00001000";
      app_en_data <= '1';
      app_data_addr <= (others => '0');
      app_data_addr(7 downto 0) <= x"FF";
      app_data_len <= std_logic_vector(to_unsigned(7, app_data_len'length));
		
      app_push <= '1';
	  
		wait until app_pushing = '1';
		
		app_push <= '0';
		
		wait until app_pushing = '0';
		
		app_dst_addr <= x"11111111";
      app_dst_port <= x"1111";
      app_ack_num  <= x"00001000";
      app_en_data <= '1';
      app_data_addr <= (others => '0');
      app_data_addr(7 downto 0) <= x"11";
      app_data_len <= std_logic_vector(to_unsigned(11, app_data_len'length));
		
      app_push <= '1';
	  
		wait until app_pushing = '1';
		
		app_push <= '0';

      wait;
   end process;
	
	read_proc: process
	begin
	   wait for 100 ns;	

      wait for CLK_period*10;
		
		wait until empty = '0';
		update <= '1';
		wait for 3 * CLK_period;
		update <= '0';
		
		wait until valid = '1' and empty = '0';		
		update <= '1';
		wait for 3 * CLK_period;
		update <= '0';
		
		wait until valid = '1' and empty = '0';		
		update <= '1';
		wait for 3 * CLK_period;
		update <= '0';
	end process;

END;
