----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:10:08 06/02/2015 
-- Design Name: 
-- Module Name:    tcp_packet_encoder - Behavioral 
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

entity tcp_packet_decoder is
	port(
		-- src_addr is the ip of the module
		-- src_addr : in std_logic_vector(31 downto 0);
		
		dst_addr : out std_logic_vector(31 downto 0);
		
		-- src_port is the port of the module
		-- src_port : in std_logic_vector(15 downto 0);
		
		dst_port : out std_logic_vector(15 downto 0);
		
		-- no need to store sequence number
		-- sequence number should be determined by sequence counter
		-- seq_num : in std_logic_vector(31 downto 0);
		
		ack_num : out std_logic_vector(31 downto 0);
		
		-- no need to encode data_offset, since our simplified
		-- module don't have options. data_offset is a constant
		data_offset : out std_logic_vector(3 downto 0);		
		
		-- flags are controlled by separate signals
		flags : out std_logic_vector(8 downto 0);
		-- some of the features are not implemented
		
		-- Window size is a constant
		window_size : out std_logic_vector(15 downto 0);
		
		-- Checksum will be calculated when the packet is to be sent
		-- checksum : in std_logic_vector(15 downto 0);
		
		-- We are not going to implement urgent, urgent_pointer is 0
		urgent_pointer : out std_logic_vector(15 downto 0);
		
		-- Indicates that whether the packet carrys a payload
		en_data : out std_logic;
		
		-- The start address in ram for the data
		data_addr : out std_logic_vector(22 downto 0);
		-- The size of data, in bytes
		data_len : out std_logic_vector(10 downto 0);
		
		-- Asynchronous reset and CLK
		nRST : in std_logic;
		CLK : in std_logic;
		
		-- control signals
		start : in std_logic; -- To start to pop data from FIFO
		valid : out std_logic;
		busy : out std_logic;
		
		-- Interface to FIFO
		encoded_data : in std_logic_vector(7 downto 0);
		rd : out std_logic
		
		);
end tcp_packet_decoder;

architecture Behavioral of tcp_packet_decoder is
	type pop_state_type is (S_IDLE, S_WAIT, S_DST_ADDR1, S_DST_ADDR2, S_DST_ADDR3,
							 S_DST_ADDR4, S_DST_PORT1, S_DST_PORT2, 
							 S_ACK_NUM1, S_ACK_NUM2, S_ACK_NUM3, S_ACK_NUM4,
							 S_FLAGS, S_EN_n_DATA_ADDR1, S_DATA_ADDR2, S_DATA_ADDR3,
							 S_DATA_LEN1, S_DATA_LEN2, S_DONE);
	signal pop_state : pop_state_type;
begin
	flags(8) <= '0';
	
	busy <= '1' when pop_state /= S_IDLE else '0';
	
	data_offset <= std_logic_vector(to_unsigned(5, data_offset'length));
	window_size <= std_logic_vector(to_unsigned(2, window_size'length));
	urgent_pointer <= std_logic_vector(to_unsigned(0, window_size'length));
	
	pop_proc: process (nRST, CLK)
	begin
		if (nRST = '0') then
			pop_state <= S_IDLE;			
			valid <= '0';
			rd <= '0';
		elsif (rising_edge(CLK)) then
			rd <= '0'; -- rd is a strobe signal
			case pop_state is
				when S_IDLE =>
					if (start = '1') then
						valid <= '0';
						rd <= '1';
						pop_state <= S_WAIT;
					end if;
					
				when S_WAIT	=>									
					dst_addr(31 downto 24) <= encoded_data;
					rd <= '1';
					pop_state <= S_DST_ADDR1;
					
				when S_DST_ADDR1 =>
					dst_addr(23 downto 16) <= encoded_data;
					rd <= '1';
					pop_state <= S_DST_ADDR2;
				
				when S_DST_ADDR2 =>
					dst_addr(15 downto 8) <= encoded_data;
					rd <= '1';
					pop_state <= S_DST_ADDR3;
					
				when S_DST_ADDR3 =>
					dst_addr(7 downto 0) <= encoded_data;
					rd <= '1';
					pop_state <= S_DST_ADDR4;
					
				when S_DST_ADDR4 =>
					dst_port(15 downto 8) <= encoded_data;
					rd <= '1';
					pop_state <= S_DST_PORT1;
					
				when S_DST_PORT1 =>
					dst_port(7 downto 0) <= encoded_data;
					rd <= '1';
					pop_state <= S_DST_PORT2;
				
				when S_DST_PORT2 =>
					ack_num(31 downto 24) <= encoded_data; 
					rd <= '1';
					pop_state <= S_ACK_NUM1;
					
				when S_ACK_NUM1 =>
					ack_num(23 downto 16) <= encoded_data;
					rd <= '1';
					pop_state <= S_ACK_NUM2;
				
				when S_ACK_NUM2 =>
					ack_num(15 downto 8) <= encoded_data;
					rd <= '1';
					pop_state <= S_ACK_NUM3;
					
				when S_ACK_NUM3 =>
					ack_num(7 downto 0) <= encoded_data;
					rd <= '1';
					pop_state <= S_ACK_NUM4;
					
				when S_ACK_NUM4 =>
					-- The flags
					flags(8) <= '0';
					flags(7 downto 0) <= encoded_data;
					rd <= '1';
					pop_state <= S_FLAGS;
					
				when S_FLAGS =>
					en_data <= encoded_data(7);
					data_addr(22 downto 16) <= encoded_data(6 downto 0);
					rd <= '1';
					pop_state <= S_EN_n_DATA_ADDR1;
				
				when S_EN_n_DATA_ADDR1 =>
					data_addr(15 downto 8) <= encoded_data;
					rd <= '1';
					pop_state <= S_DATA_ADDR2;				
					
				when S_DATA_ADDR2 =>
					data_addr(7 downto 0) <= encoded_data;
					rd <= '1';
					pop_state <= S_DATA_ADDR3;
					
				when S_DATA_ADDR3 =>
					data_len(10 downto 8) <= encoded_data(2 downto 0);
					rd <= '1';
					pop_state <= S_DATA_LEN1;
				
				when S_DATA_LEN1 =>
					data_len(7 downto 0) <= encoded_data;
					rd <= '0';
					pop_state <= S_DATA_LEN2;
				
				when S_DATA_LEN2 =>
					rd <= '0';
					pop_state <= S_DONE;
					
				when S_DONE =>
					valid <= '1';
					pop_state <= S_IDLE;
				
			end case;
		end if;
	end process;


end Behavioral;

