-- This is an FIFO implementation
-- If the FIFO is empty, pop makes no effect
-- If the FIFO is full, push makes no effect
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo is
	generic(
			-- width of data
			width : integer := 8;
			
			-- internal counter width
			-- the maximum size of the fifo is 2^(counter_width)
			counter_width : integer := 5
			
			);
	port(
			-- reset signal, active low
			nRST : in std_logic;
			
			-- clock
			CLK : in std_logic;
			
			-- data to be pushed into the FIFO
			DIN : in std_logic_vector (width-1 downto 0);
			
			-- data to be popped from the FIFO
			DOUT : out std_logic_vector (width-1 downto 0);
			
			-- indicates that data_in should be pushed into the FIFO
			PUSH : in std_logic;
			
			-- indicates that data_out should be popped from the FIFO
			POP : in std_logic;
			
			-- indicates that the FIFO is empty
			EMPTY : out std_logic;
			
			-- indicates that the FIFO is full
			FULL : out std_logic
			
			);
end fifo;

architecture Behavioral of fifo is

begin


end Behavioral;

