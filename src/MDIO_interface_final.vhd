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
			nRST: in std_logic; -- reset signal, should be a global signal
			
			-- CLK_MDC and data_MDIO are wires connected to PHY
			CLK_MDC: out std_logic; -- 2.5 MHz clock, to PHY
			data_MDIO: inout std_logic; -- between MDIO interface and PHY
			
			busy: out std_logic; -- indicate that the configuration hasn't finished, to MAC
			
			-- nWR and nRD are from the controller of MDIO
			nWR: in std_logic;-- input signal to identify whether data should be wrtten into PHY, active low
			nRD: in std_logic-- input signal to identify whether data should be read out from PHY, active low
			-- nWR and nRD are short impluse input signals, not just a signal line 

	);
end MDIO_interface;

architecture Behavioral of MDIO_interface is

	type MDIO_states is (Idle, Device_busy);
	type frame_states is (Preamble, O_A, Turn, Data);
	
	signal MDIO_state: MDIO_states := Idle;
	signal frame_state: frame_states := Preamble;

	type array_conf is array(0 to 1) of std_logic_vector(13 downto 0);
	type array_data is array(0 to 1) of std_logic_vector(15 downto 0);
	
	signal WrA: array_conf;
	signal WrD: array_data;
   signal RdA: array_conf;
	signal RdD: array_data;		
	signal count: integer := 0;
	signal count_Regi: integer := 0; 
	
	signal is_tran_finished: std_logic := '0';
	
	signal clock_25: std_logic;
	
	signal indicator: std_logic_vector(1 downto 0); -- register for write and read mode, 01: write; 10:read.

	component fre_divider is
	generic(
		counter_width : integer :=5;
		cycle: integer :=19
	);
	
	port(
		CLK: in std_logic;
		CLK_MDC: out std_logic;
		nRST: in std_logic
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
	nRST => nRST
	);
	
	WrA <= ("00000000001010","10000000001010");
	WrD <= ("0000000010000000","0000000010000000");-- the 2nd may be wrong
	RdA <= ("00000000000110","10000000000110");
	
	CLK_MDC <= clock_25;
	busy <= '1' when MDIO_state = Device_busy else '0';
	
	FSM: process(nWR, nRD, nRST, clock_25)
	begin
		if (nRST = '0') then
			MDIO_state <= Idle;
			frame_state <= Preamble;
			count_Regi <= 0;
			indicator <= "00";
			count <= 0;
			is_tran_finished <= '0';
		else
			if (falling_edge(clock_25)) then
				case MDIO_state is
					when Idle =>		
						if (nWR = '0' or nRD = '0') then
							MDIO_state <= Device_busy;
							is_tran_finished <= '0';
							frame_state <= Preamble;
							count <= 0;
							if (nWR = '0') then
								indicator <= "01";
							else
								indicator <= "10";
							end if;
						else
							data_MDIO <= '0';
						end if;
				
				
					when Device_busy =>
						case frame_state is
							when Preamble =>
								data_MDIO <= '1';
								if (count = 31) then
									frame_state <= O_A;
									count <= 0;
								else
									frame_state <= Preamble;
									count <= count + 1;
								end if;
							
							when O_A =>
								if (indicator = "01") then
										data_MDIO <= WrA(count_Regi)(count);
								elsif (indicator = "10") then
										data_MDIO <= RdA(count_Regi)(count);
								end if;
								
								if (count = 13) then
									frame_state <= Turn;
									count <= 0;
								else
									frame_state <= O_A;
									count <= count + 1;
								end if;
							
							when Turn =>
								data_MDIO <= 'Z';
								if (count = 1) then
									frame_state <= Data;
									count <= 0;
								else
									frame_state <= Turn;
									count <= count + 1;
								end if;
								
							when Data =>
								if indicator = "01" then
									data_MDIO <= WrD(count_Regi)(count);
								elsif indicator = "10" then
									RdD(count_Regi)(count) <= data_MDIO;
								end if;
								if (count = 15) then
									frame_state <= Preamble;
									count <= 0;
									if (count_Regi = 1) then
										is_tran_finished <= '1';
										count_Regi <= 0;
									else
										count_Regi <= count_Regi + 1;
									end if;
								else
									frame_state <= Data;
									count <= count + 1;
								end if;								
						end case;
						
					if (is_tran_finished = '1') then
						MDIO_state <= Idle;
					end if;
				end case;
			end if;
		end if;
	end process;
	
	
end Behavioral;

