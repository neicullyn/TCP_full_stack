-- This is an FIFO implementation
-- If the FIFO is empty, pop makes no effect
-- If the FIFO is full, push makes no effect
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity FIFO is
	port(
			-- reset signal, active low
			nRST : in std_logic;			
			-- clock
			CLK : in std_logic;
			
			-- data to be pushed into the FIFO
			DIN : in std_logic_vector (7 downto 0);			
			-- data to be popped from the FIFO
			DOUT : out std_logic_vector (7 downto 0);
			
			-- indicates that data_in should be pushed into the FIFO
			PUSH : in std_logic;			
			-- indicates that data_out should be popped from the FIFO
			POP : in std_logic;
			
			-- indicates that the FIFO is empty
			EMPTY : out std_logic;			
			-- indicates that the FIFO is full
			FULL : out std_logic
			
			);
end FIFO;

architecture Behavioral of FIFO is
	COMPONENT BlockRAM_1024x8
	PORT(
		clka : IN std_logic;
		ena : IN std_logic;
		wea : IN std_logic_vector(0 to 0);
		addra : IN std_logic_vector(9 downto 0);
		dina : IN std_logic_vector(7 downto 0);
		clkb : IN std_logic;
		enb : IN std_logic;
		addrb : IN std_logic_vector(9 downto 0);          
		doutb : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	
	-- Head pointer
	signal head : unsigned(9 downto 0);
	-- Rear pointer
	signal rear : unsigned(9 downto 0);
	
	signal COUNT_dummy : unsigned(9 downto 0);
	
	signal EMPTY_dummy : std_logic;
	signal FULL_dummy : std_logic;
	
	signal PUSH_internal : std_logic;
	signal POP_internal : std_logic;
	
	-- RAM enable
	signal ena : std_logic;
	signal enb : std_logic;
	-- RAM Write enable
	signal wea : std_logic_vector(0 downto 0);
	-- RAM address
	signal addra: std_logic_vector(9 downto 0);
	signal addrb: std_logic_vector(9 downto 0);
	-- RAM DIN
	signal dina : std_logic_vector(7 downto 0);
	-- RAM DOUT
	signal doutb : std_logic_vector(7 downto 0);
	
	type DOUT_MUX_TYPE is (DIRECT, BUFF);
	signal DOUT_mux : DOUT_MUX_TYPE;
	
	signal DOUT_buff: std_logic_vector(7 downto 0);
	
begin
		Inst_BlockRAM_1024x8: BlockRAM_1024x8 PORT MAP(
		clka => CLK,
		ena => ena,
		wea => wea,
		addra => addra,
		dina => dina,
		clkb => CLK,
		enb => enb,
		addrb => addrb,
		doutb => doutb
	);
	
	EMPTY <= EMPTY_dummy;
	FULL <= FULL_dummy;
	
	EMPTY_dummy <= '1' when (head = rear) else '0';
	FULL_dummy <= '1' when (rear + 1 = head) else '0';
	
	PUSH_internal <= PUSH and not FULL_dummy;
	POP_internal <= POP and not EMPTY_dummy;
	
	-- Always write
	wea(0) <= '1';
	
	-- When reading(pop), the address of the next element to pop is head + 1
	-- When writing(push), the address of the element to write is rear
	addra <= std_logic_vector(rear);
	addrb <= std_logic_vector(head + 1);
	
	-- The DIN of the RAM is always DIN of the module
	dina <= DIN;

	ena <= PUSH_internal;
	
	-- If count = 1, then should not access memory, as
	-- head + 1 is invalid
	enb <= '1' when (POP_internal = '1' and COUNT_dummy /= 1) else '0';
	
	-- DOUT is either douta or the buffered douta
	DOUT <= doutb when (DOUT_mux = DIRECT) else DOUT_buff;
	
	main_proc : process(nRST, CLK)
	begin 
		if (nRST = '0') then
			-- Aynchronous Reset
			-- No need to reset RAM
			head <= to_unsigned(0, head'length);
			rear <= to_unsigned(0, rear'length);
			COUNT_dummy <= to_unsigned(0, COUNT_dummy'length);
			
			DOUT_mux <= DIRECT;
		elsif (rising_edge(CLK)) then
			if (PUSH_internal = '1' and POP_internal = '0') then
				-- PUSH				
				rear <= rear + 1;
				COUNT_dummy <= COUNT_dummy + 1;
				
				if (EMPTY_dummy = '1') then
					-- If the buffer is empty, copy DIN to DOUT_buff
					DOUT_buff <= DIN;
					DOUT_mux <= BUFF;
				end if;
			end if;
			
			if (PUSH_internal = '0' and POP_internal = '1') then
				-- POP
				head <= head + 1;
				COUNT_dummy <= COUNT_dummy - 1;			
				
				-- doutb is the data we want
				DOUT_mux <= DIRECT;
			end if;
			
			if (PUSH_internal = '1' and POP_internal = '1') then
				-- PUSH and POP
				head <= head + 1;
				rear <= rear + 1;
				COUNT_dummy <= COUNT_dummy;
				
				if (COUNT_dummy = 1) then
					-- after push and pop, store the 
					-- data in DOUT_buff
					DOUT_buff <= DIN;
					DOUT_mux <= BUFF;
				else
					-- doutb is the data we want (if the fifo is not empty)
					DOUT_mux <= DIRECT;
				end if;
			end if;
			
		end if;
	end process;

end Behavioral;

