----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:34:27 06/02/2015 
-- Design Name: 
-- Module Name:    tcp_make_ack_packet - Behavioral 
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

entity tcp_make_ack_packet is
	port (
			in_src_addr : in std_logic_vector(31 downto 0);
			in_dst_addr : in std_logic_vector(31 downto 0);
			
			in_src_port : in std_logic_vector(15 downto 0);
			in_dst_port : in std_logic_vector(15 downto 0);
			
			in_seq_num : in std_logic_vector(31 downto 0);
			in_ack_num : in std_logic_vector(31 downto 0);
			
			syn : in std_logic;
			
			fin : in std_loigc;
			
			out_src_addr : out std_logic_vector(31 downto 0);
			out_dst_addr : out std_logic_vector(31 downto 0);
			
			out_src_port : out std_logic_vector(15 downto 0);
			out_dst_port : out std_logic_vector(15 downto 0);
			
			out_seq_num : out std_logic_vector(31 downto 0);
			out_ack_num : out std_logic_vector(31 downto 0);
			
			out_data_offset : out std_logic_vector(3 downto 0);
			out_flags : out std_logic_vector(8 downto 0);			
			out_window_size : out std_logic_vector(15 downto 0);
			
			out_urgent_pointer : out std_logic_vector(15 downto 0);
			
			);
			
			
			
end tcp_make_ack_packet;

architecture Behavioral of tcp_make_ack_packet is

begin
	out_src_addr <= in_dst_addr;
	out_dst_addr <= in_src_addr;
	
	out_src_port <= in_dst_port;
	out_dst_port <= in_src_port;
	
	


end Behavioral;

