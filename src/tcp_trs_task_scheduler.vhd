----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:40:52 06/03/2015 
-- Design Name: 
-- Module Name:    tcp_trs_task_scheduler - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tcp_trs_task_scheduler is
	port(
		-- For protocol core
		
		core_dst_addr : in std_logic_vector(31 downto 0);
		core_dst_port : in std_logic_vector(15 downto 0);
		core_ack_num : in std_logic_vector(31 downto 0);
		core_ack : in std_logic;
		core_rst : in std_logic;
		core_syn : in std_logic;
		core_fin : in std_logic;
		
		-- Push the core packet info into the scheduler
		-- Note that core_push has higher priority than app_push
		core_push : in std_logic;
		core_pushing : out std_logic;
		
		-- Packet generate by the protocol doesn't have payload
		-- en_data : in std_logic;		
		-- data_addr : in std_logic_vector(22 downto 0);
		-- data_len : in std_logic_vector(10 downto 0);		
		
		-- For upper layer (application)
		app_dst_addr : in std_logic_vector(31 downto 0);
		app_dst_port : in std_logic_vector(15 downto 0);
		app_ack_num : in std_logic_vector(31 downto 0);
		
		-- Application layer doesn't set flags (for our simplified implementation)
		-- ack : in std_logic;
		-- rst : in std_logic;
		-- syn : in std_logic;
		-- fin : in std_logic;
		
		app_en_data : in std_logic;		
		app_data_addr : in std_logic_vector(22 downto 0);
		app_data_len : in std_logic_vector(10 downto 0);
		
		-- Push the app packet info into the scheduler
		app_push : in std_logic;		
		app_pushing : out std_logic;
		
		-- Output
		dst_addr : out std_logic_vector(31 downto 0);
		dst_port : out std_logic_vector(15 downto 0);
		ack_num : out std_logic_vector(31 downto 0);
		data_offset : out std_logic_vector(3 downto 0);		
		flags : out std_logic_vector(8 downto 0);
		window_size : out std_logic_vector(15 downto 0);
		urgent_pointer : out std_logic_vector(15 downto 0);
		
		en_data : out std_logic;
		data_addr : out std_logic_vector(22 downto 0);
		data_len : out std_logic_vector(10 downto 0);

		-- Control signals for output
		valid : out std_logic;
		update : in std_logic; -- indicates that the output has been used
							   -- and needs updating
		empty : out std_logic; -- indicates the queue is empty
		
		-- Asynchronous reset and CLK
		nRST : in std_logic;
		CLK : in std_logic
	);
end tcp_trs_task_scheduler;

architecture Behavioral of tcp_trs_task_scheduler is
	COMPONENT tcp_packet_encoder
	PORT(
		dst_addr : IN std_logic_vector(31 downto 0);
		dst_port : IN std_logic_vector(15 downto 0);
		ack_num : IN std_logic_vector(31 downto 0);
		ack : IN std_logic;
		rst : IN std_logic;
		syn : IN std_logic;
		fin : IN std_logic;
		en_data : IN std_logic;
		data_addr : IN std_logic_vector(22 downto 0);
		data_len : IN std_logic_vector(10 downto 0);
		nRST : IN std_logic;
		CLK : IN std_logic;
		start : IN std_logic;          
		busy : OUT std_logic;
		encoded_data : OUT std_logic_vector(7 downto 0);
		wr : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT tcp_packet_decoder
	PORT(
		nRST : IN std_logic;
		CLK : IN std_logic;
		start : IN std_logic;
		encoded_data : IN std_logic_vector(7 downto 0);          
		dst_addr : OUT std_logic_vector(31 downto 0);
		dst_port : OUT std_logic_vector(15 downto 0);
		ack_num : OUT std_logic_vector(31 downto 0);
		data_offset : OUT std_logic_vector(3 downto 0);
		flags : OUT std_logic_vector(8 downto 0);
		window_size : OUT std_logic_vector(15 downto 0);
		urgent_pointer : OUT std_logic_vector(15 downto 0);
		en_data : OUT std_logic;
		data_addr : OUT std_logic_vector(22 downto 0);
		data_len : OUT std_logic_vector(10 downto 0);
		valid : OUT std_logic;
		busy : OUT std_logic;
		rd : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT FIFO
	PORT(
		nRST : IN std_logic;
		CLK : IN std_logic;
		DIN : IN std_logic_vector(7 downto 0);
		PUSH : IN std_logic;
		POP : IN std_logic;          
		DOUT : OUT std_logic_vector(7 downto 0);
		EMPTY : OUT std_logic;
		FULL : OUT std_logic
		);
	END COMPONENT;
	
	signal count : unsigned (5 downto 0);  -- At most 63 packet waiting
	
	signal e_dst_addr : std_logic_vector(31 downto 0);
	signal e_dst_port : std_logic_vector(15 downto 0);
	signal e_ack_num : std_logic_vector(31 downto 0);
	signal e_ack : std_logic;
	signal e_rst : std_logic;
	signal e_syn : std_logic;
	signal e_fin : std_logic;
	signal e_en_data : std_logic;
	signal e_data_addr : std_logic_vector(22 downto 0);
	signal e_data_len : std_logic_vector(10 downto 0);
	
	signal e_busy : std_logic;
	signal e_start : std_logic;
	
	signal e_encoded_data : std_logic_vector(7 downto 0);
	signal e_wr : std_logic;
	
	signal d_start : std_logic;
	signal d_valid : std_logic;
	signal d_busy : std_logic;
	signal d_encoded_data : std_logic_vector(7 downto 0);
	signal d_rd : std_logic;
	
	signal FIFO_empty : std_logic;
	signal FIFO_full : std_logic;
	
	type push_state_type is (S_IDLE, S_WAIT1, S_WAIT2);
	signal push_state : push_state_type;
	
	type pop_state_type is (S_IDLE, S_WAIT1, S_WAIT2);
	signal pop_state : pop_state_type;
	
begin
	Inst_tcp_packet_encoder: tcp_packet_encoder PORT MAP(
		dst_addr => e_dst_addr,
		dst_port => e_dst_port,
		ack_num => e_ack_num,
		ack => e_ack,
		rst => e_rst,
		syn => e_syn,
		fin => e_fin,
		en_data => e_en_data,
		data_addr => e_data_addr,
		data_len => e_data_len,
		nRST => nRST,
		CLK => CLK,
		busy => e_busy,
		start => e_start,
		encoded_data => e_encoded_data,
		wr => e_wr
	);
	
	Inst_tcp_packet_decoder: tcp_packet_decoder PORT MAP(
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
		nRST => nRST,
		CLK => CLK,
		start => d_start,
		valid => d_valid,
		busy => d_busy,
		encoded_data => d_encoded_data,
		rd => d_rd
	);
	
	Inst_FIFO: FIFO PORT MAP(
		nRST => nRST,
		CLK => CLK,
		DIN => e_encoded_data,
		DOUT => d_encoded_data,
		PUSH => e_wr,
		POP => d_rd,
		EMPTY => FIFO_empty,
		FULL => FIFO_full 
	);
	empty <= '1' when count = 0 else '0';
	
	scheduler_proc: process (nRST, CLK)
	begin
		if (nRST = '0') then
			valid <= '0';
			core_pushing <= '0';
			app_pushing <= '0';
			
			e_start <= '0';
			d_start <= '0';
			
			count <= to_unsigned(0, count'length);
		elsif (rising_edge(CLK)) then
			-- The length of e_start and d_start is 1 cycle
			e_start <= '0';
			d_start <= '0';
			
			-- Handle push request
			case push_state is
				when S_IDLE =>
					if (core_push = '1') then
					-- Handle push request from core
						e_dst_addr <= core_dst_addr;
						e_dst_port <= core_dst_port;
						e_ack_num <= core_ack_num;
						e_ack <= core_ack;
						e_rst <= core_rst;
						e_syn <= core_syn;
						e_fin <= core_fin;
						e_en_data <= '0';
						e_data_addr <= (others => '0');
						e_data_len <= (others => '0');
						e_start <= '1';
						
						core_pushing <= '1';
						push_state <= S_WAIT1;
						
					elsif (app_push = '1') then
					-- Handle push request from app
						e_dst_addr <= app_dst_addr;
						e_dst_port <= app_dst_port;
						e_ack_num <= app_ack_num;
						e_ack <= '0';
						e_rst <= '0';
						e_syn <= '0';
						e_fin <= '0';
						e_en_data <= app_en_data;
						e_data_addr <= app_data_addr;
						e_data_len <= app_data_len;
						e_start <= '1';
						
						app_pushing <= '1';
						push_state <= S_WAIT1;						
					end if;
					
				when S_WAIT1 =>
					if (e_busy = '1') then
						push_state <= S_WAIT2;
					end if;
					
				when S_WAIT2 =>
					if (e_busy = '0') then
						core_pushing <= '0';
						app_pushing <= '0';
						count <= count + 1;
						push_state <= S_IDLE;
					end if;
			end case;
			
			case pop_state is
				when S_IDLE =>
					if (count /= 0 and update = '1') then
						-- Going to update
						valid <= '0';
						d_start <= '1';
						
						pop_state <= S_WAIT1;
					end if;
					
				when S_WAIT1 =>
					if (d_busy = '1') then
						pop_state <= S_WAIT2;
					end if;
					
				when S_WAIT2=>
					if (d_busy = '0') then
						valid <= '1';
						if (push_state = S_WAIT2 and e_busy = '0') then
						-- Push and Pop are completed simultaneously
							count <= count;
						else
							count <= count - 1;
						end if;
						pop_state <= S_IDLE;
					end if;
			end case;
				
		end if;
	end process;

end Behavioral;

