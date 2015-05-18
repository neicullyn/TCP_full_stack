----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:55:40 05/17/2015 
-- Design Name: 
-- Module Name:    Test_RAM - Behavioral 
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

entity Test_RAM is
	port(
			-- Clock
			CLK : in  STD_LOGIC;
			
			-- Switches and buttons
			SW : in  STD_LOGIC_VECTOR (7 downto 0);
			BTN : in  STD_LOGIC_VECTOR (4 downto 0);
			
			-- Digits
			SSEG_CA : out  STD_LOGIC_VECTOR (7 downto 0);
			SSEG_AN : out  STD_LOGIC_VECTOR (3 downto 0);
				
			-- LED
			LED : out  STD_LOGIC_VECTOR (7 downto 0);
			
			-- UART
			UART_RXD : in std_logic;
			UART_TXD : out std_logic;
			
			-- RAM	
			-- Address bus
			ADDR : out std_logic_vector(25 downto 0);			
			-- Data bus
			DATA : inout std_logic_vector(15 downto 0);			
			-- Clock
			CLK_out : out std_logic;			
			-- Chip enable
			nCE : out std_logic;			
			-- Write enable
			nWE : out std_logic;			
			-- Output enable
			nOE : out std_logic;					
			-- Address valied
			nADV : out std_logic;			
			-- Control register enable
			CRE : out std_logic;			
			-- Lower bits enable
			nLB : out std_logic;
			-- Higher bits enable
			nUB : out std_logic;			
			-- Wait : Data not valid, active low
			WAIT_in : in std_logic
			
			
			
			);
end Test_RAM;

architecture Behavioral of Test_RAM is
	COMPONENT btn_debounce
	PORT(
		BTN_I : IN std_logic_vector(4 downto 0);
		CLK : IN std_logic;          
		BTN_O : OUT std_logic_vector(4 downto 0)
		);
	END COMPONENT;
	
	COMPONENT RAM_Controller
	PORT(
		WAIT_in : IN std_logic;
		CLK : IN std_logic;
		nRST : IN std_logic;
		ADDR_base : IN std_logic_vector(22 downto 0);
		N_WORDS : IN std_logic_vector(9 downto 0);
		DIN : IN std_logic_vector(15 downto 0);
		WR : IN std_logic;
		RD : IN std_logic;    
		DATA : INOUT std_logic_vector(15 downto 0);      
		ADDR : OUT std_logic_vector(22 downto 0);
		CLK_out : OUT std_logic;
		nCE : OUT std_logic;
		nWE : OUT std_logic;
		nOE : OUT std_logic;
		nADV : OUT std_logic;
		CRE : OUT std_logic;
		nLB : OUT std_logic;
		nUB : OUT std_logic;
		DOUT : OUT std_logic_vector(15 downto 0);
		BUSY : OUT std_logic;
		DINU : OUT std_logic;
		DOUTV : OUT std_logic
		);
	END COMPONENT;

	COMPONENT UART_w_FIFO
	PORT(
		nRST : IN std_logic;
		CLK : IN std_logic;
		RX_serial : IN std_logic;
		DIN : IN std_logic_vector(7 downto 0);
		WR : IN std_logic;
		RD : IN std_logic;          
		TX_serial : OUT std_logic;
		FULL : OUT std_logic;
		DOUT : OUT std_logic_vector(7 downto 0);
		DOUTV : OUT std_logic
		);
	END COMPONENT;
	
	
	signal nRST : std_logic;
	
	signal BTN_db : std_logic_vector(4 downto 0);
	signal BTN_d : std_logic_vector(4 downto 0);
	signal rising_BTN : std_logic_vector(4 downto 0);
	signal falling_BTN : std_logic_vector(4 downto 0);
	
	signal RAM_ADDR_base : std_logic_vector(22 downto 0);
	signal RAM_N_WORDS : std_logic_vector (9 downto 0);
	signal RAM_DIN : std_logic_vector(15 downto 0);
	signal RAM_DOUT : std_logic_vector(15 downto 0);
	signal RAM_BUSY : std_logic;
	signal RAM_WR : std_logic;
	signal RAM_RD : std_logic;
	signal RAM_DINU : std_logic;
	signal RAM_DOUTV : std_logic;
	
	signal UART_DIN : std_logic_vector(7 downto 0);
	signal UART_DOUT : std_logic_vector(7 downto 0);
	signal UART_WR : std_logic;
	signal UART_RD : std_logic;
	signal UART_DOUTV : std_logic;
	signal UART_FULL :std_logic;
	
	type TEST_RAM_LOGIC_STATE is (IDLE, STATE_WRITE, WRITE_DONE, STATE_READ, READ_DONE);
	signal test_ram_logic : TEST_RAM_LOGIC_STATE;
	
begin
	UART_DIN <= RAM_DOUT(7 downto 0);
	UART_WR <= RAM_DOUTV;

	Inst_UART_w_FIFO: UART_w_FIFO PORT MAP(
		nRST => nRST,
		CLK => CLK,
		RX_serial => UART_RXD,
		TX_serial => UART_TXD,
		DIN => UART_DIN,
		WR => UART_WR,
		FULL => UART_FULL,
		DOUT => UART_DOUT,
		RD => UART_RD,
		DOUTV => UART_DOUTV
	);
	
	Inst_btn_debounce: btn_debounce PORT MAP(
		BTN_I => BTN,
		CLK => CLK,
		BTN_O => BTN_db
	);
	
	ADDR(25 downto 23) <= "000";
	Inst_RAM_Controller: RAM_Controller PORT MAP(
		ADDR => ADDR(22 downto 0),
		DATA => DATA,
		CLK_out => CLK_out,
		nCE => nCE,
		nWE => nWE,
		nOE => nOE,
		nADV => nADV,
		CRE => CRE,
		nLB => nLB,
		nUB => nUB,
		WAIT_in => WAIT_in,
		
		CLK => CLK,
		nRST => nRST,
		
		ADDR_base => RAM_ADDR_base,
		N_WORDS => RAM_N_WORDS,
		DIN => RAM_DIN,
		DOUT => RAM_DOUT,
		BUSY => RAM_BUSY,
		WR => RAM_WR,
		RD => RAM_RD,
		DINU => RAM_DINU,
		DOUTV => RAM_DOUTV
	);
	
	SSEG_CA <= x"FF";
	SSEG_AN <= x"F";
	
	
	process(CLK)
	begin
		if(rising_edge(CLK)) then
			BTN_d <= BTN_db;
		end if;
	end process;
	
	process(BTN_db, BTN_d)
	begin 
		for i in 0 to 4 loop
		
			if BTN_d(i)='0' and BTN_db(i)='1' then
				rising_BTN(i) <= '1';
			else
				rising_BTN(i) <= '0';
			end if;
			
			if BTN_d(i)='1' and BTN_db(i)='0' then
				falling_BTN(i) <= '1';
			else
				falling_BTN(i) <= '0';
			end if;
			
		end loop;
	end process;
	
	nRST <= not BTN(4);
	
	process (test_ram_logic)
	begin
		case test_ram_logic is
			when IDLE =>
				LED <= x"01";
			when STATE_WRITE =>
				LED <= x"02";
			when WRITE_DONE =>
				LED <= x"04";
			when STATE_READ =>
				LED <= x"08";
			when READ_DONE =>
				LED <= x"10";
		end case;
	end process;
	
	test_ram_proc: process(nRST, CLK)
	begin
		if(nRST = '0') then
			RAM_WR <= '0';
			RAM_RD <= '0';
			test_ram_logic <= IDLE;
		elsif(rising_edge(CLK)) then
			case test_ram_logic is
				when IDLE =>
					if(RAM_BUSY = '0') then
						-- Goto next state if initializion has been completed
						test_ram_logic <= STATE_WRITE;
					end if;
				when STATE_WRITE =>
					RAM_ADDR_base <= std_logic_vector(to_unsigned(0, RAM_ADDR_base'length));
					RAM_N_WORDS <= std_logic_vector(to_unsigned(8, RAM_N_WORDS'length));
					RAM_DIN <= x"FAFB";
					RAM_WR <= '1';
					RAM_RD <= '0';
					if(RAM_BUSY = '1') then
						test_ram_logic <= WRITE_DONE;
					end if;
				when WRITE_DONE =>
					RAM_WR <= '0';
					if(RAM_BUSY = '0') then
						test_ram_logic <= STATE_READ;
					end if;
					
				when STATE_READ =>
					RAM_ADDR_base <= std_logic_vector(to_unsigned(0, RAM_ADDR_base'length));
					RAM_N_WORDS <= std_logic_vector(to_unsigned(8, RAM_N_WORDS'length));
					RAM_DIN <= x"FAFB";
					RAM_WR <= '0';
					RAM_RD <= '1';
					if(RAM_BUSY = '1') then
						test_ram_logic <= READ_DONE;
					end if;					
				when READ_DONE =>
				
			end case;
		end if;
	end process;

end Behavioral;

