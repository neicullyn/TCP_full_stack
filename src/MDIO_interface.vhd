----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:32:57 05/03/2015 
-- Design Name: 
-- Module Name:    MDIO_interface - Behavioral 
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
use IEEE.numeric_std.ALL;-- for unsigned


entity MDIO_interface is
	port(
			CLK: in std_logic; -- the system clock 100MHz
			nRST: in std_logic;-- reset signal, should be a global signal
			
			-- CLK_MDC and data_MDIO are wires connected to PHY
			CLK_MDC: out std_logic; -- 2.5 MHz clock, to PHY
			data_MDIO: inout std_logic; -- between MDIO interface and PHY
			
			busy: out std_logic; -- indicate that the configuration hasn't finished, to MAC
			
			-- nWR and nRD are from the controller of MDIO
			nWR: in std_logic;-- input signal to identify whether data should be wrtten into PHY, active low
			nRD: in std_logic-- input signal to identify whether data should be read out from PHY, active low
			

	);
end MDIO_interface;

architecture Behavioral of MDIO_interface is

	type States is (Idle, Preamble, O_A, Turn, Data); -- FSM
	signal state: States;

	type array_WrA is array(0 to 1) of std_logic_vector(13 downto 0);
	type array_WrD is array(0 to 1) of std_logic_vector(15 downto 0);
	type array_RdA is array(0 to 1) of std_logic_vector(13 downto 0);
	type array_RdD is array(0 to 1) of std_logic_vector(15 downto 0);
	signal temp_WrA: array_WrA;
	signal temp_WrD: array_WrD;
   signal temp_RdA: array_RdA;
	signal temp_RdD: array_RdD;	
	
	signal count: integer := 0;
	--signal count: unsigned(4 downto 0) := "00000"; -- counter
	--signal count: std_logic :='0';
	--integer count_Fmax := 31;
	
	
	--signal count_Regi: unsigned := '0';
	signal count_Regi: unsigned(4 downto 0) := "00000"; -- counter for PHY registers when writing
	--signal count_Regi_Rd: unsigned(4 downto 0) := "00000"; -- counter for PHY registers when reading
	--signal count_Rout: std_logic;	
	constant Regi_Wr_max : unsigned(4 downto 0) := to_unsigned(31, 5);-- from 31 to 5-bit unsigned
	constant Regi_Rd_max : unsigned(4 downto 0) := to_unsigned(31, 5);
	--constant Regi_Wr_max : unsigned := '1';-- from 31 to 5-bit unsigned
	--constant Regi_Rd_max : unsigned := '1';
	
	
	signal EN_counter: std_logic;-- enable signal for the counter
	signal data_write: std_logic_vector(15 downto 0);
	signal data_read: std_logic_vector(15 downto 0);
	
	signal clock_25: std_logic;
	signal clock_5M: std_logic;

	component fre_divider is
	generic(
		counter_width : integer :=5;
		cycle: integer :=19
	);
	
	port(
		CLK: in std_logic;
		CLK_MDC: out std_logic;
		nRST: in std_logic;-- global reset signal, can initialize the DFF, active low
		CLK_5M: out std_logic
	);
	end component;
	
begin
	frequency_divider: fre_divider
	generic map(
	counter_width => 5,
	cycle => 19
	)
	port map(
	CLK => CLK,
	CLK_MDC => clock_25,
	nRST => nRST,
	CLK_5M => clock_5M
	);
	
	-- suppose we don't have nRST signal now
	-- Register 1, Address: 0, Basic Control Register
	-- 
	temp_WrA <= ("01010000000000","01010000000001");
	temp_WrD <= ("0000000100000000","0000000100000000");-- the 2nd may be wrong
	temp_RdA <= ("01100000000000","01100000000001");
	

	CLK_MDC <= clock_25;
	-- how to set count=0 in each 			
	-- for sequential logic:	
	
	Counter_and_FSM: process(clock_25,clock_5M,count)
		begin
		
		if (nRST = '0') then
			state <= Idle; --?
		else
			if (nWR = '0') and (nRD = '1') then -- Write state
				if count_Regi /= Regi_Wr_max then -- write all PHY address that are necessary
				
					if clock_25='1' and clock_5M = '1' then -- data is on the MDIO databus when falling edge of MDC	
																		 -- data is latched in PHY when rising edge of next MDC
						case state is
							when Idle =>
								state <= Preamble;
								--end if;
							when Preamble =>
								count <= 0;
								if (count = 31) then
									state <= O_A;
									count <= 0;
									data_MDIO <= '0';
								else 
									state <= Preamble;
									count <= count + 1;
								end if;
							when O_A =>
								if (count = 13) then
									state <= Turn;
									if (nRD = '0') then
										data_MDIO <= 'Z'; -- in the read mode, we need to set MDIO Z state
															 -- so it this databus can switch from out to in 
									end if;
									count <= 0;
								else
									state <= O_A;				
									if (nWR='0') and (nRD='1') then --write
										data_MDIO <= temp_WrA(to_integer(count_Regi))(count);
									elsif (nWR='1') and (nRD='0') then
										temp_RdA(to_integer(count_Regi))(count) <= data_MDIO;
									end if;
									count <= count + 1;
								end if;
							when Turn =>
								if (count = 2) then
									state <= Data;
								else 
									state <= Turn;
									count <= count + 1;
								end if;
								
							when Data =>
								if (count = 15) then
									state <= Idle;
									count <= 0;
								else
									if (nWR='0') and (nRD='1') then --write
										data_MDIO <= temp_WrD(to_integer(count_Regi))(count);
									elsif (nWR='1') and (nRD='0') then
										temp_RdD(to_integer(count_Regi))(count) <= data_MDIO;
									end if;
									count <= count + 1;
								end if;
						end case;
						count_Regi <= count_Regi + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

