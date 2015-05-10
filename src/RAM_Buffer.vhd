----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:48:54 05/09/2015 
-- Design Name: 
-- Module Name:    RAM_buffer - Behavioral 
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

entity RAM_buffer is
	port(
			-- reset signal, active low
			nRST : in std_logic;			
			
			-- clock
			CLK : in std_logic;
			
			-- Another reset signal
			RESET : in std_logic;
			
			-- data to be pushed into the FIFO
			DIN : in std_logic_vector (15 downto 0);			
			-- data to be popped from the FIFO
			DOUT : out std_logic_vector (15 downto 0);
			
			-- When PUSH = '1' and POP = '1', it will not do anything
			-- indicates that data_in should be pushed into the FIFO
			PUSH : in std_logic;			
			-- indicates that data_out should be popped from the FIFO
			POP : in std_logic;
			
			-- Number of entries, note that it only counts to 1023
			COUNT : out std_logic_vector(9 downto 0);
			
			-- Note that there is no check of whether the buffer is 
			-- empty of full when trying to push or pop.
			
			-- indicates that the FIFO is empty
			EMPTY : out std_logic;			
			-- indicates that the FIFO is full
			FULL : out std_logic
			
			);
end RAM_buffer;

architecture Behavioral of RAM_buffer is

	COMPONENT BlockRAM
	PORT(
		clka : IN std_logic;
		ena : IN std_logic;
		wea : IN std_logic_vector(0 to 0);
		addra : IN std_logic_vector(9 downto 0);
		dina : IN std_logic_vector(15 downto 0);          
		douta : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	-- Head pointer
	signal head : unsigned(9 downto 0);
	-- Rear pointer
	signal rear : unsigned(9 downto 0);
	
	signal COUNT_dummy : unsigned(9 downto 0);
	
	signal EMPTY_dummy : std_logic;
	signal FULL_dummy : std_logic;
	
	-- RAM enable
	signal ena : std_logic;
	-- RAM Write enable
	signal wea : std_logic_vector(0 downto 0);
	-- RAM address
	signal addra: std_logic_vector(9 downto 0);
	-- RAM DIN
	signal dina : std_logic_vector(15 downto 0);
	-- RAM DOUT
	signal douta : std_logic_vector(15 downto 0);
	
	type DOUT_MUX_TYPE is (DIRECT, BUFF);
	signal DOUT_mux : DOUT_MUX_TYPE;
	
	signal DOUT_buff: std_logic_vector(15 downto 0);
	
begin
	Inst_BlockRAM: BlockRAM PORT MAP(
		clka => CLK,
		ena => ena,
		wea => wea,
		addra => addra,
		dina => dina,
		douta => douta 
	);
	
	COUNT <= std_logic_vector(COUNT_dummy);
	EMPTY <= EMPTY_dummy;
	FULL <= FULL_dummy;
	
	EMPTY_dummy <= '1' when (head = rear) else '0';
	FULL_dummy <= '1' when (rear + 1 = head) else '0';
	
	-- Write is the same as PUSH
	wea(0) <= PUSH;
	
	-- When reading(pop), the address of the next element to pop is head + 1
	-- When writing(push), the address of the element to write is rear
	addra <= std_logic_vector(head + 1) when (PUSH = '0') else std_logic_vector(rear);
	
	-- The DIN of the RAM is always DIN of the module
	dina <= DIN;
	-- If push is different from pop, the RAM should be enable
	ena <= PUSH xor POP;
	
	-- DOUT is either douta or the buffered douta
	DOUT <= douta when (DOUT_mux = DIRECT) else DOUT_buff;
	
	main_proc : process(nRST, RESET, CLK)
	begin 
		if (nRST = '0' or RESET = '1') then
			-- Aynchronous Reset
			-- No need to reset RAM
			head <= to_unsigned(0, head'length);
			rear <= to_unsigned(0, rear'length);
			COUNT_dummy <= to_unsigned(0, COUNT_dummy'length);
			
			DOUT_mux <= DIRECT;
		elsif (rising_edge(CLK)) then
			if (PUSH = '1' and POP = '0') then
				-- PUSH
				
				rear <= rear + 1;
				COUNT_dummy <= COUNT_dummy + 1;
				
				if (EMPTY_dummy = '1') then
					-- If the buffer is empty, copy DIN to DOUT_buff
					DOUT_buff <= DIN;
					DOUT_mux <= BUFF;
				else
					-- If douta is valid, buffer douta, and use the buffer as
					-- DOUT, since douta is going to be invalid
					if (DOUT_mux = DIRECT) then
						DOUT_buff <= douta;
					end if;
					
					DOUT_mux <= BUFF;				
				end if;
				

			end if;
			
			if (PUSH = '0' and POP = '1') then
				-- POP
				head <= head + 1;
				COUNT_dummy <= COUNT_dummy - 1;			
				
				-- douta is the data we want
				DOUT_mux <= DIRECT;
			end if;
			
		end if;
	end process;
end Behavioral;

