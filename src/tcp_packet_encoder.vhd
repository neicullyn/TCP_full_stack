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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tcp_packet_encoder is
	port(
		-- src_addr is the ip of the module
		-- src_addr : in std_logic_vector(31 downto 0);
		
		dst_addr : in std_logic_vector(31 downto 0);
		
		-- src_port is the port of the module
		-- src_port : in std_logic_vector(15 downto 0);
		
		dst_port : in std_logic_vector(15 downto 0);
		
		-- no need to store sequence number
		-- sequence number should be determined by sequence counter
		-- seq_num : in std_logic_vector(31 downto 0);
		
		ack_num : in std_logic_vector(31 downto 0);
		
		-- no need to encode data_offset, since our simplified
		-- module don't have options. data_offset is a constant
		-- data_offset : in std_logic_vector(3 downto 0);		
		
		-- flags are controlled by separate signals
		-- flags : in std_logic_vector(9 downto 0);
		-- some of the features are not implemented
		-- ns : in std_logic;
		-- cwr : in std_logic;
		-- ece : in std_logic;
		-- urg : in std_logic;
		ack : in std_logic;
		-- psh : in std_logic;
		rst : in std_logic;
		syn : in std_logic;
		fin : in std_logic;
		
		-- Window size is a constant
		-- window_size : in std_logic_vector(15 downto 0);
		
		-- Checksum will be calculated when the packet is to be sent
		-- checksum : in std_logic_vector(15 downto 0);
		
		-- We are not going to implement urgent, urgent_pointer is 0
		-- urgent_pointer : in std_logic_vector(15 downto 0);
		
		-- Indicates that whether the packet carrys a payload
		en_data : in std_logic;
		
		-- The start address in ram for the data
		data_addr : in std_logic_vector(22 downto 0);
		-- The size of data, in bytes
		data_len : in std_logic_vector(10 downto 0);
		
		-- Asynchronous reset and CLK
		nRST : in std_logic;
		CLK : in std_logic;
		
		-- control signals
		busy : out std_logic; -- Indicates that the module
							  -- is pushing data into FIFO
							  
		start : in std_logic; -- To start to push data into FIFO
		
		-- Interface to FIFO
		encoded_data : out std_logic_vector(7 downto 0);
		wr : out std_logic
		
		);
end tcp_packet_encoder;

architecture Behavioral of tcp_packet_encoder is
	type push_state_type is (S_IDLE, S_DST_ADDR1, S_DST_ADDR2, S_DST_ADDR3,
							 S_DST_ADDR4, S_DST_PORT1, S_DST_PORT2, 
							 S_ACK_NUM1, S_ACK_NUM2, S_ACK_NUM3, S_ACK_NUM4,
							 S_FLAGS, S_EN_n_DATA_ADDR1, S_DATA_ADDR2, S_DATA_ADDR3,
							 S_DATA_LEN1, S_DATA_LEN2, S_DONE);
	signal push_state : push_state_type;
begin
	busy <= '1' when push_state /= S_IDLE else '0';
	
	push_proc: process (nRST, CLK)
	begin
		if (nRST = '0') then
			push_state <= S_IDLE;
			wr <= '0';	
		elsif (rising_edge(CLK)) then
			wr <= '0'; -- wr is a strobe signal
			case push_state is
				when S_IDLE =>
					if (start = '1') then
						encoded_data <= dst_addr(31 downto 24);
						wr <= '1';
						push_state <= S_DST_ADDR1;
					end if;
					
				when S_DST_ADDR1 =>
					encoded_data <= dst_addr(23 downto 16);
					wr <= '1';
					push_state <= S_DST_ADDR2;
				
				when S_DST_ADDR2 =>
					encoded_data <= dst_addr(15 downto 8);
					wr <= '1';
					push_state <= S_DST_ADDR3;
					
				when S_DST_ADDR3 =>
					encoded_data <= dst_addr(7 downto 0);
					wr <= '1';
					push_state <= S_DST_ADDR4;
					
				when S_DST_ADDR4 =>
					encoded_data <= dst_port(15 downto 8);
					wr <= '1';
					push_state <= S_DST_PORT1;
					
				when S_DST_PORT1 =>
					encoded_data <= dst_port(7 downto 0);
					wr <= '1';
					push_state <= S_DST_PORT2;
				
				when S_DST_PORT2 =>
					encoded_data <= ack_num(31 downto 24);
					wr <= '1';
					push_state <= S_ACK_NUM1;
					
				when S_ACK_NUM1 =>
					encoded_data <= ack_num(23 downto 16);
					wr <= '1';
					push_state <= S_ACK_NUM2;
				
				when S_ACK_NUM2 =>
					encoded_data <= ack_num(15 downto 8);
					wr <= '1';
					push_state <= S_ACK_NUM3;
					
				when S_ACK_NUM3 =>
					encoded_data <= ack_num(7 downto 0);
					wr <= '1';
					push_state <= S_ACK_NUM4;
					
				when S_ACK_NUM4 =>
					-- The flags
					encoded_data <= "000" & ack & '0' & rst & syn & fin;
					wr <= '1';
					push_state <= S_FLAGS;
					
				when S_FLAGS =>
					encoded_data <= en_data & data_addr(22 downto 16);
					wr <= '1';
					push_state <= S_EN_n_DATA_ADDR1;
				
				when S_EN_n_DATA_ADDR1 =>
					encoded_data <= data_addr(15 downto 8);
					wr <= '1';
					push_state <= S_DATA_ADDR2;				
					
				when S_DATA_ADDR2 =>
					encoded_data <= data_addr(7 downto 0);
					wr <= '1';
					push_state <= S_DATA_ADDR3;
					
				when S_DATA_ADDR3 =>
					encoded_data <= "00000" & data_len(10 downto 8);
					wr <= '1';
					push_state <= S_DATA_LEN1;
				
				when S_DATA_LEN1 =>
					encoded_data <= data_len(7 downto 0);
					wr <= '1';
					push_state <= S_DATA_LEN2;
				
				when S_DATA_LEN2 =>
					encoded_data <= "00000000";
					wr <= '0';
					push_state <= S_DONE;
					
				when S_DONE =>
					push_state <= S_IDLE;
				
			end case;
		end if;
	end process;


end Behavioral;

