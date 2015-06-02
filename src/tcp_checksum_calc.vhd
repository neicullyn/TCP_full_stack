----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:18 06/02/2015 
-- Design Name: 
-- Module Name:    tcp_checksum_calc - Behavioral 
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

entity tcp_checksum_calc is
	port (
			-- Note:
			-- All the signals are not buffered
			-- Make sure that the signals are not changed until
			-- checksum_out_valid = '1'
			
			-- Pseudo Header
			src_addr : in std_logic_vector(31 downto 0);
			dst_addr : in std_logic_vector(31 downto 0);
			reserved : in std_logic_vector(7 downto 0);
			protocol : in std_logic_vector(7 downto 0);
			tcp_segment_length : in std_logic_vector(15 downto 0);
			
			-- TCP Header
			src_port : in std_logic_vector(15 downto 0);
			dst_port : in std_logic_vector(15 downto 0);
			seq_num : in std_logic_vector(31 downto 0);
			ack_num : in std_logic_vector(31 downto 0);
			data_offset : in std_logic_vector(3 downto 0);
			flags : in std_logic_vector(8 downto 0);
			window_size : in std_logic_vector(15 downto 0);
			checksum_in : in std_logic_vector(15 downto 0);
			urgent_pointer : in std_logic_vector(15 downto 0);
			
			-- Options should be handled by external module
			checksum_for_options : in std_logic_vector(15 downto 0);
			checksum_for_options_valid : in std_logic;
			
			-- Data should be handled by external module
			checksum_for_data : in std_logic_vector(15 downto 0);
			checksum_for_data_valid : in std_logic;
			
			-- Checksum output
			checksum_out : out std_logic_vector(15 downto 0);
			checksum_out_valid : out std_logic;
			success : out std_logic;
			
			-- Control Signals
			nRST : in std_logic;
			CLK : in std_logic;
			start : in std_logic
		);			
end tcp_checksum_calc;

architecture Behavioral of tcp_checksum_calc is
	type checksum_calc_state_type is (S_IDLE, S_SRC_ADDR1, S_SRC_ADDR2,
											S_DST_ADDR1, S_DST_ADDR2,
											S_RES_n_PRTCL, S_SEG_LEN,
											S_SRC_PORT, S_DST_PORT,
											S_SEQ_NUM1, S_SEQ_NUM2,
											S_ACK_NUM1, S_ACK_NUM2,
											S_OFST_n_FLAGS, S_WINDOW_SIZE,
											S_CHECKSUM_IN, S_URGENT_POINTER,
											S_OPTIONS, S_DATA,
											S_DONE);
											
	signal checksum_calc_state : checksum_calc_state_type;
	
											
											
	signal result : unsigned(15 downto 0);
begin
	process (nRST, CLK)
	begin
		if (nRST = '0') then
			result <= x"0000";
			
			checksum_out_valid <= '0';
			success <= '1';
			
			checksum_calc_state <= S_IDLE;
			
		elsif (rising_edge(CLK)) then
		
			case checksum_calc_state is
			
				when S_IDLE =>
					if (start = '1') then
						result <= x"0000";
						
						checksum_out_valid <= '0';
						success <= '0';
						
						checksum_calc_state <= S_SRC_ADDR1;						
						
					end if;
					
				when S_SRC_ADDR1 =>
					result <= result + unsigned(src_addr(31 downto 16));
					checksum_calc_state <= S_SRC_ADDR2;
				
				when S_SRC_ADDR2 =>
					result <= result + unsigned(src_addr(15 downto 0));
					checksum_calc_state <= S_DST_ADDR1;
				
				when S_DST_ADDR1 =>
					result <= result + unsigned(dst_addr(31 downto 16));
					checksum_calc_state <= S_DST_ADDR2;
				
				when S_DST_ADDR2 =>
					result <= result + unsigned(dst_addr(15 downto 0));
					checksum_calc_state <= S_RES_n_PRTCL;
					
				when S_RES_n_PRTCL =>
					result <= result + unsigned(reserved & protocol);
					checksum_calc_state <= S_SEG_LEN;
				
				when S_SEG_LEN =>
					result <= result + unsigned(tcp_segment_length);
					checksum_calc_state <= S_SRC_PORT;
				
				when S_SRC_PORT =>
					result <= result + unsigned(src_port);
					checksum_calc_state <= S_DST_PORT;
				
				when S_DST_PORT =>
					result <= result + unsigned(dst_port);
					checksum_calc_state <= S_SEQ_NUM1;
					
				when S_SEQ_NUM1 =>
					result <= result + unsigned(seq_num(31 downto 16));
					checksum_calc_state <= S_SEQ_NUM2;
				
				when S_SEQ_NUM2 =>
					result <= result + unsigned(seq_num(15 downto 0));
					checksum_calc_state <= S_ACK_NUM1;
				
				when S_ACK_NUM1 =>
					result <= result + unsigned(ack_num(31 downto 16));
					checksum_calc_state <= S_ACK_NUM2;
					
				when S_ACK_NUM2 =>
					result <= result + unsigned(ack_num(15 downto 0));
					checksum_calc_state <= S_OFST_n_FLAGS;
				
				when S_OFST_n_FLAGS =>
					result <= result + unsigned(data_offset & "000" & flags);
					checksum_calc_state <= S_WINDOW_SIZE;
				
				when S_WINDOW_SIZE =>
					result <= result + unsigned(window_size);
					checksum_calc_state <= S_CHECKSUM_IN;
				
				when S_CHECKSUM_IN =>
					result <= result + unsigned(checksum_in);
					checksum_calc_state <= S_URGENT_POINTER;
				
				when S_URGENT_POINTER =>
					result <= result + unsigned(urgent_pointer);
					checksum_calc_state <= S_OPTIONS;
				
				when S_OPTIONS =>
					if (checksum_for_options_valid = '1') then
						result <= result + unsigned(checksum_for_options);
						checksum_calc_state <= S_DATA;
					end if;
					
				when S_DATA =>
					if (checksum_for_data_valid = '1') then
						result <= result + unsigned(checksum_for_data);
						checksum_calc_state <= S_DONE;
					end if;
				
				when S_DONE =>
					checksum_out <= not std_logic_vector(result);
					checksum_out_valid <= '1';
					if( result = x"FFFF") then
						success <= '1';
					else
						success <= '0';
					end if;
					checksum_calc_state <= S_IDLE;			
				
			end case;
		end if;
	end process;

end Behavioral;

