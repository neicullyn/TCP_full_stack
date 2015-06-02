----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:56 05/27/2015 
-- Design Name: 
-- Module Name:    TCP - Behavioral 
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

entity TCP is
	port (
			-- Asynchonous reset
			nRST : in std_logic;
			
			-- Clock
			CLK : in std_logic;
			
			-- TXD to the underlying module
			TXDU : out std_logic_vector(7 downto 0);
			TXDUV : out std_logic;
			RdU : in std_logic;
			
			-- RXD from the underlying module
			RXDU : in std_logic_vector(7 downto 0);
			WrU : in std_logic;
			
			EOL : in std_logic
			);
end TCP;

architecture Behavioral of TCP is
	-- Receiver
	type packet_rcv_state_type is (S_SRC_PORT, S_DST_PORT, S_SEQ_NUM, S_ACK_NUM, S_DATA_OFFSET, S_FLAGS, 
									  S_WINDOW_SIZE, S_CHECKSUM, S_URGENT_POINTER, S_OPTIONS, S_DATA, S_HANDLE, S_DUMP);
	signal packet_rcv_state : packet_rcv_state_type;
	
	signal rcv_counter : unsigned(10 downto 0); -- 11-bit counter, 0~2047
	signal rcv_counter_inc : unsigned(10 downto 0); -- rcv_counter + 1
	signal rcv_aux_counter : unsigned(1 downto 0); -- Smaller counter for rcv
	
	signal rcv_src_port : std_logic_vector(15 downto 0);
	signal rcv_dst_port : std_logic_vector(15 downto 0);
	signal rcv_seq_num : std_logic_vector(31 downto 0);
	signal rcv_ack_num : std_logic_vector(31 downto 0);
	signal rcv_data_offset : std_logic_vector(3 downto 0);
	signal rcv_flags : std_logic_vector(8 downto 0);
	signal rcv_window_size : std_logic_vector(15 downto 0);
	signal rcv_checksum : std_logic_vector(15 downto 0);
	signal rcv_urgent_pointer : std_logic_vector(15 downto 0);
	
	-- Transimiter
	type packet_trs_state_type is (S_IDLE, S_SRC_PORT, S_DST_PORT, S_SEQ_NUM, S_ACK_NUM, S_DATA_OFFSET, S_FLAGS,
										S_WINDOW_SIZE, S_CHECKSUM, S_URGENT_POINTER, S_DATA, S_HANDLE);
	signal packet_trs_state: packet_trs_state_type;
	
	signal trs_counter : unsigned(10 downto 0); -- 11-bit counter, 0~2047
	signal trs_counter_inc : unsigned(10 downto 0); -- rcv_counter + 1
	signal trs_aux_counter : unsigned(1 downto 0); -- Smaller counter for rcv
	
	signal trs_src_port : std_logic_vector(15 downto 0);
	signal trs_dst_port : std_logic_vector(15 downto 0);
	signal trs_seq_num : std_logic_vector(31 downto 0);
	signal trs_ack_num : std_logic_vector(31 downto 0);
	signal trs_data_offset : std_logic_vector(3 downto 0);
	signal trs_flags : std_logic_vector(8 downto 0);
	signal trs_window_size : std_logic_vector(15 downto 0);
	signal trs_checksum : std_logic_vector(15 downto 0);
	signal trs_urgent_pointer : std_logic_vector(15 downto 0);
	
	-- TCP Protocol
	
	type tcp_state_type is (S_CLOSED, S_LISTEN, S_SYN_RECEIVED, S_SYN_SENT, S_ESTABLISHED,
						S_FIN_WAIT1, S_FIN_WAIT2, S_CLOSING, S_TIME_WAIT, S_CLOSE_WAIT, S_LAST_ACK);
						
	signal tcp_state : tcp_state_type;
	
	signal p_listen : std_logic;
	signal p_setup : std_logic;
	signal p_stop : std_logic;
	
	signal p_syn : std_logic;
	signal p_rst : std_logic;
	signal p_ack : std_logic;
	signal p_fin : std_logic;
	
	signal p_timeout: std_logic;
	
	signal p_timeout_CLOSE_WAIT : std_logic;
	signal p_timeout_TIME_WAIT : std_logic;
	
	
begin
	rcv_counter_inc <= rcv_counter + 1;
	
	rcv_proc : process (nRST, CLK)
	begin
		if(nRST = '0') then
			packet_rcv_state <= S_SRC_PORT;
			rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
			rcv_counter <= to_unsigned(0, rcv_counter'length);
		elsif (rising_edge(CLK)) then
			if(WrU = '1') then
				-- New data arrive
				rcv_counter <= rcv_counter_inc;
				case packet_rcv_state is						
					when S_SRC_PORT =>
						if (rcv_aux_counter = 0) then
							-- This byte is the first byte of src_port
							rcv_src_port(15 downto 8) <= RXDU;
							
							rcv_aux_counter <= rcv_aux_counter + 1;
						else
							-- This byte is the second byte of src_port
							rcv_src_port(7 downto 0) <= RXDU;
							
							packet_rcv_state <= S_DST_PORT;
							rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
						end if;
						
					when S_DST_PORT =>
						if (rcv_aux_counter = 0) then
							-- This byte is the first byte of dst_port
							rcv_dst_port(15 downto 8) <= RXDU;
							
							rcv_aux_counter <= rcv_aux_counter + 1;
						else
							-- This byte is the second byte of dst_port
							rcv_dst_port(7 downto 0) <= RXDU;
							
							packet_rcv_state <= S_SEQ_NUM;
							rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
						end if;
						
					when S_SEQ_NUM =>
						case rcv_aux_counter is 
							when "00" =>							
							-- First byte
								rcv_seq_num(31 downto 24) <= RXDU;
							when "01" =>
							-- Second byte
								rcv_seq_num(23 downto 16) <= RXDU;
							when "10" =>
							-- Third byte
								rcv_seq_num(15 downto 8) <= RXDU;
							when others =>
							-- Last byte
								rcv_seq_num(7 downto 0) <= RXDU;
								
								packet_rcv_state <= S_ACK_NUM;
						end case;
						-- rcv_aux_counter: 0->1->2->3->0
						rcv_aux_counter <= rcv_aux_counter + 1;
						
					when S_ACK_NUM =>
						case rcv_aux_counter is 
							when "00" =>							
							-- First byte
								rcv_ack_num(31 downto 24) <= RXDU;
							when "01" =>
							-- Second byte
								rcv_ack_num(23 downto 16) <= RXDU;
							when "10" =>
							-- Third byte
								rcv_ack_num(15 downto 8) <= RXDU;
							when others =>
							-- Last byte
								rcv_ack_num(7 downto 0) <= RXDU;
								
								packet_rcv_state <= S_DATA_OFFSET;
						end case;
						-- rcv_aux_counter: 0->1->2->3->0
						rcv_aux_counter <= rcv_aux_counter + 1;
						
					when S_DATA_OFFSET =>
						rcv_data_offset <= RXDU(7 downto 4);
						rcv_flags(8) <= RXDU(0);						
						packet_rcv_state <= S_FLAGS;
						
					when S_FLAGS =>
						rcv_flags(7 downto 0) <= RXDU;						
						packet_rcv_state <= S_WINDOW_SIZE;
						
					when S_WINDOW_SIZE =>
						if (rcv_aux_counter = 0) then
							-- This byte is the first byte of window_size
							rcv_window_size(15 downto 8) <= RXDU;
							
							rcv_aux_counter <= rcv_aux_counter + 1;
						else
							-- This byte is the second byte of window_size
							rcv_window_size(7 downto 0) <= RXDU;
							
							packet_rcv_state <= S_CHECKSUM;
							rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
						end if;
						
					when S_CHECKSUM =>
						if (rcv_aux_counter = 0) then
							-- This byte is the first byte of checksum
							rcv_checksum(15 downto 8) <= RXDU;
							
							rcv_aux_counter <= rcv_aux_counter + 1;
						else
							-- This byte is the second byte of checksum
							rcv_checksum(7 downto 0) <= RXDU;
							
							packet_rcv_state <= S_URGENT_POINTER;
							rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
						end if;
						
					when S_URGENT_POINTER =>
						if (rcv_aux_counter = 0) then
							-- This byte is the first byte of urgent_pointer
							rcv_urgent_pointer(15 downto 8) <= RXDU;
							
							rcv_aux_counter <= rcv_aux_counter + 1;
						else
							-- This byte is the second byte of urgent_pointer
							rcv_urgent_pointer(7 downto 0) <= RXDU;
							
							packet_rcv_state <= S_CHECKSUM;
							rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
						end if;
						
					when S_OPTIONS =>
						-- Ignore options
						if ( rcv_counter_inc(rcv_counter_inc'length - 1 downto 6) = 0
							  and std_logic_vector(rcv_counter_inc(5 downto 2)) = rcv_data_offset
							  and rcv_counter_inc(1 downto 0) = to_unsigned(0, 2) ) then
							-- rcv_counter_inc = data_offset * 4
							-- The next byte is the first byte of data
							packet_rcv_state <= S_DATA;
							rcv_counter <= to_unsigned(0, rcv_counter'length);
						end if;
					when S_DATA =>
						-- TODO
						if ( EOL = '1') then
							-- Last byte
							packet_rcv_state <= S_HANDLE;
						end if;
					when S_HANDLE =>
						-- TODO
					
					when S_DUMP =>
						if (EOL = '1') then
							-- If the packet should be ignored, return to 
							-- the first state when the packet is over
							packet_rcv_state <= S_SRC_PORT;
							rcv_aux_counter <= to_unsigned(0, rcv_aux_counter'length);
							rcv_counter <= to_unsigned(0, rcv_counter'length);
						end if;
				end case;
			end if;
		end if;
	end process;

	
	trs_counter_inc <= trs_counter;
	trs_proc: process (nRST, CLK)
	begin
		if(nRST = '0') then
			packet_trs_state <= S_IDLE;
			trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
			trs_counter <= to_unsigned(0, trs_counter'length);
		elsif (rising_edge(CLK)) then
			if(RdU = '1' or packet_trs_state = S_IDLE) then
				if(packet_trs_state /= S_IDLE) then
					trs_counter <= trs_counter_inc;
				end if;
				case packet_trs_state is
					when S_IDLE =>
						TXDU <= trs_src_port(15 downto 8);
						trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
						
						packet_trs_state <= S_SRC_PORT;
						
					when S_SRC_PORT =>
						if(trs_aux_counter = 0) then
							TXDU <= trs_src_port(7 downto 0);
							trs_aux_counter <= trs_aux_counter + 1;
						else
							TXDU <= trs_dst_port(15 downto 8);
							trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
							
							packet_trs_state <= S_DST_PORT;
						end if;
						
					when S_DST_PORT =>
						if(trs_aux_counter = 0) then
							TXDU <= trs_dst_port(7 downto 0);
							trs_aux_counter <= trs_aux_counter + 1;
						else
							TXDU <= trs_seq_num(31 downto 24);
							trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
							
							packet_trs_state <= S_SEQ_NUM;
						end if;
						
					when S_SEQ_NUM =>
						case trs_aux_counter is
							when "00" =>
							-- First byte is over
								TXDU <= trs_seq_num(23 downto 16);
							when "01" =>
							-- Second byte is over
								TXDU <= trs_seq_num(15 downto 8);
							when "10" =>
							-- Third byte is over
								TXDU <= trs_seq_num(7 downto 0);
							when others =>
							-- Forth byte is over
								TXDU <= trs_ack_num(31 downto 24);
								
								packet_trs_state <= S_ACK_NUM;
						end case;
						-- trs_aux_counter: 0->1->2->3->0
						trs_aux_counter <= trs_aux_counter + 1;
						
					when S_ACK_NUM =>
						case trs_aux_counter is
							when "00" =>
							-- First byte is over
								TXDU <= trs_ack_num(23 downto 16);
							when "01" =>
							-- Second byte is over
								TXDU <= trs_ack_num(15 downto 8);
							when "10" =>
							-- Third byte is over
								TXDU <= trs_ack_num(7 downto 0);
							when others =>
							-- Forth byte is over
							-- Output data offset
								TXDU(7 downto 4) <= trs_data_offset;
								TXDU(3 downto 1) <= "000";
								TXDU(0) <= trs_flags(8);
								
								packet_trs_state <= S_DATA_OFFSET;
						end case;
						-- trs_aux_counter: 0->1->2->3->0
						trs_aux_counter <= trs_aux_counter + 1;
					
					when S_DATA_OFFSET =>
						-- Data offset is over, output flags
						TXDU <= trs_flags(7 downto 0);
						packet_trs_state <= S_FLAGS;
					
					when S_FLAGS =>
						-- Flags are transmitted, output window_size
						TXDU <= trs_window_size(15 downto 8);
						trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
						
						packet_trs_state <= S_WINDOW_SIZE;
					
					when S_WINDOW_SIZE =>
						if(trs_aux_counter = 0) then
							-- The first byte is over
							TXDU <= trs_window_size(7 downto 0);
							
							trs_aux_counter <= trs_aux_counter + 1;
						else
							-- The Second byte is over
							TXDU <= trs_checksum(15 downto 8);
							
							trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
							packet_trs_state <= S_CHECKSUM;
						end if;
					
					when S_CHECKSUM =>
						if(trs_aux_counter = 0) then
							-- The first byte is over
							TXDU <= trs_checksum(7 downto 0);
							
							trs_aux_counter <= trs_aux_counter + 1;
						else
							-- The second byte is over
							TXDU <= trs_urgent_pointer(15 downto 8);
							
							trs_aux_counter <= to_unsigned(0, trs_aux_counter'length);
							packet_trs_state <= S_URGENT_POINTER;
						end if;
					
					when S_URGENT_POINTER =>
						if(trs_aux_counter = 0) then
							-- The first byte is over
							TXDU <= trs_urgent_pointer(7 downto 0);
							
							trs_aux_counter <= trs_aux_counter + 1;
						else
							-- TODO
							-- The second byte is over
							-- Start transmitting data
							
							-- TXDU <= S_DATA
							packet_trs_state <= S_DATA;
						end if;
					
					when S_DATA =>
						-- TODO
						-- Has not been completed
						packet_trs_state <= S_HANDLE;
					
					when S_HANDLE =>
						packet_trs_state <= S_IDLE;						
				end case;
			end if;		
		end if;
	end process;
	
	
	protocol_proc: process (nRST, CLK)
	begin
		if(nRST = '0') then
			tcp_state <= S_CLOSED;
		elsif(rising_edge(CLK)) then
			case tcp_state is
				when S_CLOSED =>
					if (p_listen = '1') then
						tcp_state <= S_LISTEN;
					elsif (p_setup = '1') then
						-- TODO
						-- Send Syn packet and sent here
						tcp_state <= S_SYN_SENT;
					end if;
					
				when S_LISTEN =>
					if (p_syn = '1') then
						-- TODO
						-- Record where the syn comes from
						
						-- TODO
						-- Send SYN + ACK
						
						-- TODO
						-- Setup Timer
						tcp_state <= S_SYN_RECEIVED;
					end if;
					
				when S_SYN_RECEIVED =>
					if (p_ack = '1') then
						-- Need to check if this is the correct sender
						tcp_state <= S_ESTABLISHED;
					end if;
				
				when S_SYN_SENT =>
					if (p_syn = '1' and p_ack = '0') then
						-- Simutaneous Open
						
						-- TODO
						-- Send ACK
						
						tcp_state <= S_SYN_RECEIVED;
					end if;
					
					if (p_syn = '1' and p_ack = '1') then
					
						tcp_state <= S_ESTABLISHED;
					end if;
				
				when S_ESTABLISHED =>
					if (p_stop = '1') then
						-- Active stop
						
						-- TODO
						-- Send FIN
						tcp_state <= S_FIN_WAIT1;
					end if;
					
					if (p_fin = '1') then
						-- Passive stop
						
						-- TODO
						-- Send ACK
						
						-- TODO
						-- Setup CLOSE_WAIT_TIMER
						tcp_state <= S_CLOSE_WAIT;
					end if;
					
				when S_FIN_WAIT1 =>
					if (p_ack = '1') then
						tcp_state <= S_FIN_WAIT2;
					end if;
					
					if (p_fin = '1') then
						-- Simutaneous Close
						
						-- TODO
						-- Send ACK
						tcp_state <= S_CLOSING;
					end if;
				
				when S_FIN_WAIT2 =>
					if (p_fin = '1') then
						-- TODO
						-- Send ACK
						
						-- TODO
						-- Setup TIME_WAIT_TIMER
						tcp_state <= S_TIME_WAIT;
					end if;
				
				when S_CLOSING =>
					if (p_ack = '1') then
						-- TODO
						-- Setup TIME_WAIT_TIMER
						tcp_state <= S_TIME_WAIT;
					end if;
				
				when S_TIME_WAIT =>
					if (p_timeout_TIME_WAIT = '1') then
						tcp_state <= S_CLOSED;
					end if;
					
				when S_CLOSE_WAIT =>
					if (p_timeout_CLOSE_WAIT = '1') then
						-- TODO
						-- Send FIN
						tcp_state <= S_LAST_ACK;
					end if;
					
				when S_LAST_ACK =>
					if (p_ack = '1') then
						tcp_state <= S_CLOSED;
					end if;
					
					
				
			end case;
		end if;
	end process;
end Behavioral;

