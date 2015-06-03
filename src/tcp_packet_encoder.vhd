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
		data_len : in std_logic_vector(11 downto 0);
		
		);
end tcp_packet_encoder;

architecture Behavioral of tcp_packet_encoder is

begin


end Behavioral;

