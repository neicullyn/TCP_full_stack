----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:48:54 05/09/2015 
-- Design Name: 
-- Module Name:    FIFO_16bit - Behavioral 
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

entity FIFO_16bit is
	port(
			-- reset signal, active low
			nRST : in std_logic;			
			-- clock
			CLK : in std_logic;
			
			-- data to be pushed into the FIFO
			DIN : in std_logic_vector (15 downto 0);			
			-- data to be popped from the FIFO
			DOUT : out std_logic_vector (15 downto 0);
			
			-- indicates that data_in should be pushed into the FIFO
			PUSH : in std_logic;			
			-- indicates that data_out should be popped from the FIFO
			POP : in std_logic;
			
			-- Number of entries
			COUNT out std_logic;
			-- indicates that the FIFO is empty
			EMPTY : out std_logic;			
			-- indicates that the FIFO is full
			FULL : out std_logic
			
			);
end FIFO_16bit;

architecture Behavioral of FIFO_16bit is
	signal head : unsigned(9 downto 0);
	signal rear : unsigned(9 downto 0);
	
	signal COUNT_dummy : unsigned(9 downto 0);
	
	signal EMPTY_dummy : std_logic;
	signal FULL_dummy : std_logic;
	

begin
	COUNT <= COUNT_dummy;
	EMPTY <= EMPTY_dummy;
	FULL <= FULL_dummy;
	
	EMPTY_dummy <= 1 when (head = rear) else 0;
	FULL_dummy <= 1 when (rear = head - 1) else 0;
	
	main_proc : process(nRST, CLK)
	begin 
		if (nRST = '0') then
			-- Aynchronous Reset
			head <= to_unsigned(0, head'length);
			rear <= to_unsigned(0, rear'length);
			COUNT_dummy <= to_unsigned(0, COUNT_dummy'length);
		elsif (rising_edge(CLK) then
			if (PUSH = '1') then
		end if;
	end process;
end Behavioral;

