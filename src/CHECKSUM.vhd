----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:06:29 05/31/2015 
-- Design Name: 
-- Module Name:    CHECKSUM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: This module computes the checksum for a stream of data. To
-- use this module, pass in the data byte by byte starting from the most significant 
-- byte. For example, to compute the checksum of 4500003044224000800600008c7c19acae241e2b,
-- which is a 20 bytes long IP header, pass in the data in the sequence of 45, 00, 00, etc.
-- For each byte, say 45, pass in as DATA(7 downto 0) = X"45"
-- The data register is 16 bit, so pass in the first byte with SELB = 0 and then the second
-- byte with SELB = 1
-- When both bytes are ready, calculate the new checksum by asserting CALC
-- To read off the final checksum, set REQ = 1, and then read off the first byte with SELB = 0
-- and then read off the second byte with SELB = 1. Say if the final checksum is 4d3e, then 
-- SELB = 0 sets CHKSUM(7 downto 0) = X"4d" and SELB = 1 sets CHKSUM(7 downto 0) = X"3e".
-- The functional priority is INIT, REQ and then CALC.  
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

entity CHECKSUM is
    Port ( CLK : in  STD_LOGIC; -- global clock
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);   -- input data bus
           nRST : in  STD_LOGIC; -- global reset, active low
			  INIT : in STD_LOGIC; -- clear internal registers
           D_VALID : in  STD_LOGIC; -- data valid, new checksum is calculated when both bytes are ready
			  CALC: in STD_LOGIC; -- calculate new checksum
           REQ : in  STD_LOGIC; -- request the final output
			  SELB : in STD_LOGIC; -- select the byte to latch in, 0 for MSB, 1 for LSB
           CHKSUM : out  STD_LOGIC_VECTOR (7 downto 0)); -- the output bus for final 16-bit checksum
end CHECKSUM;

architecture Behavioral of CHECKSUM is

 function cal_chksum
    (
        data_in :   std_logic_vector(15 downto 0);
        chksum_in  :   std_logic_vector(31 downto 0)
    )
    return std_logic_vector is

    variable d:      std_logic_vector(15 downto 0);
    variable c:      std_logic_vector(31 downto 0);
    variable newchk: std_logic_vector(31 downto 0);
	 variable carry:  std_logic_vector(31 downto 0);

    begin
        d := data_in;
        c := chksum_in;
        
        newchk(0) := d(0) xor c(0);
		  carry(0) := d(0) and c(0);
        newchk(1) := d(1) xor c(1) xor carry(0);
		  carry(1) := (d(1) and c(1)) or (carry(0) and (d(1) xor c(1)));
		  newchk(2) := d(2) xor c(2) xor carry(1);
		  carry(2) := (d(2) and c(2)) or (carry(1) and (d(2) xor c(2)));
		  newchk(3) := d(3) xor c(3) xor carry(2);
		  carry(3) := (d(3) and c(3)) or (carry(2) and (d(3) xor c(3)));
		  newchk(4) := d(4) xor c(4) xor carry(3);
		  carry(4) := (d(4) and c(4)) or (carry(3) and (d(4) xor c(4)));
		  newchk(5) := d(5) xor c(5) xor carry(4);
		  carry(5) := (d(5) and c(5)) or (carry(4) and (d(5) xor c(5)));
		  newchk(6) := d(6) xor c(6) xor carry(5);
		  carry(6) := (d(6) and c(6)) or (carry(5) and (d(6) xor c(6)));
		  newchk(7) := d(7) xor c(7) xor carry(6);
		  carry(7) := (d(7) and c(7)) or (carry(6) and (d(7) xor c(7)));
		  newchk(8) := d(8) xor c(8) xor carry(7);
		  carry(8) := (d(8) and c(8)) or (carry(7) and (d(8) xor c(8)));
		  newchk(9) := d(9) xor c(9) xor carry(8);
		  carry(9) := (d(9) and c(9)) or (carry(8) and (d(9) xor c(9)));
		  newchk(10) := d(10) xor c(10) xor carry(9);
		  carry(10) := (d(10) and c(10)) or (carry(9) and (d(10) xor c(10)));
		  newchk(11) := d(11) xor c(11) xor carry(10);
		  carry(11) := (d(11) and c(11)) or (carry(10) and (d(11) xor c(11)));
		  newchk(12) := d(12) xor c(12) xor carry(11);
		  carry(12) := (d(12) and c(12)) or (carry(11) and (d(12) xor c(12)));
		  newchk(13) := d(13) xor c(13) xor carry(12);
		  carry(13) := (d(13) and c(13)) or (carry(12) and (d(13) xor c(13)));
		  newchk(14) := d(14) xor c(14) xor carry(13);
		  carry(14) := (d(14) and c(14)) or (carry(13) and (d(14) xor c(14)));
		  newchk(15) := d(15) xor c(15) xor carry(14);
		  carry(15) := (d(15) and c(15)) or (carry(14) and (d(15) xor c(15)));
		  newchk(16) := c(16) xor carry(15);
		  carry(16) :=  c(16) and carry(15);
		  newchk(17) := c(17) xor carry(16);
		  carry(17) :=  c(17) and carry(16);
		  newchk(18) := c(18) xor carry(17);
		  carry(18) :=  c(18) and carry(17);
		  newchk(19) := c(19) xor carry(18);
		  carry(19) :=  c(19) and carry(18);
		  newchk(20) := c(20) xor carry(19);
		  carry(20) :=  c(20) and carry(19);
		  newchk(21) := c(21) xor carry(20);
		  carry(21) :=  c(21) and carry(20);
		  newchk(22) := c(22) xor carry(21);
		  carry(22) :=  c(22) and carry(21);
		  newchk(23) := c(23) xor carry(22);
		  carry(23) :=  c(23) and carry(22);
		  newchk(24) := c(24) xor carry(23);
		  carry(24) :=  c(24) and carry(23);
		  newchk(25) := c(25) xor carry(24);
		  carry(25) :=  c(25) and carry(24);
		  newchk(26) := c(26) xor carry(25);
		  carry(26) :=  c(26) and carry(25);
		  newchk(27) := c(27) xor carry(26);
		  carry(27) :=  c(27) and carry(26);
		  newchk(28) := c(28) xor carry(27);
		  carry(28) :=  c(28) and carry(27);
		  newchk(29) := c(29) xor carry(28);
		  carry(29) :=  c(29) and carry(28);
		  newchk(30) := c(30) xor carry(29);
		  carry(30) :=  c(30) and carry(29);
		  newchk(31) := c(31) xor carry(30);
		  carry(31) :=  c(31) and carry(30);
		  
        return newchk;
 end cal_chksum;
	 
 function ret_chksum
    (
        chksum_in :   std_logic_vector(31 downto 0)
    )
    return std_logic_vector is

	 variable d: std_logic_vector(15 downto 0);
	 variable c: std_logic_vector(15 downto 0);
    variable chk: std_logic_vector(15 downto 0);
	 variable carry:  std_logic_vector(15 downto 0);

    begin
        d := chksum_in(15 downto 0);
        c := chksum_in(31 downto 16);
        
        chk(0) := d(0) xor c(0) xor '1';
		  carry(0) := d(0) and c(0);
        chk(1) := d(1) xor c(1) xor carry(0) xor '1';
		  carry(1) := (d(1) and c(1)) or (carry(0) and (d(1) xor c(1)));
		  chk(2) := d(2) xor c(2) xor carry(1) xor '1';
		  carry(2) := (d(2) and c(2)) or (carry(1) and (d(2) xor c(2)));
		  chk(3) := d(3) xor c(3) xor carry(2) xor '1';
		  carry(3) := (d(3) and c(3)) or (carry(2) and (d(3) xor c(3)));
		  chk(4) := d(4) xor c(4) xor carry(3) xor '1';
		  carry(4) := (d(4) and c(4)) or (carry(3) and (d(4) xor c(4)));
		  chk(5) := d(5) xor c(5) xor carry(4) xor '1';
		  carry(5) := (d(5) and c(5)) or (carry(4) and (d(5) xor c(5)));
		  chk(6) := d(6) xor c(6) xor carry(5) xor '1';
		  carry(6) := (d(6) and c(6)) or (carry(5) and (d(6) xor c(6)));
		  chk(7) := d(7) xor c(7) xor carry(6) xor '1';
		  carry(7) := (d(7) and c(7)) or (carry(6) and (d(7) xor c(7)));
		  chk(8) := d(8) xor c(8) xor carry(7) xor '1';
		  carry(8) := (d(8) and c(8)) or (carry(7) and (d(8) xor c(8)));
		  chk(9) := d(9) xor c(9) xor carry(8) xor '1';
		  carry(9) := (d(9) and c(9)) or (carry(8) and (d(9) xor c(9)));
		  chk(10) := d(10) xor c(10) xor carry(9) xor '1';
		  carry(10) := (d(10) and c(10)) or (carry(9) and (d(10) xor c(10)));
		  chk(11) := d(11) xor c(11) xor carry(10) xor '1';
		  carry(11) := (d(11) and c(11)) or (carry(10) and (d(11) xor c(11)));
		  chk(12) := d(12) xor c(12) xor carry(11) xor '1';
		  carry(12) := (d(12) and c(12)) or (carry(11) and (d(12) xor c(12)));
		  chk(13) := d(13) xor c(13) xor carry(12) xor '1';
		  carry(13) := (d(13) and c(13)) or (carry(12) and (d(13) xor c(13)));
		  chk(14) := d(14) xor c(14) xor carry(13) xor '1';
		  carry(14) := (d(14) and c(14)) or (carry(13) and (d(14) xor c(14)));
		  chk(15) := d(15) xor c(15) xor carry(14) xor '1';
		  carry(15) := (d(15) and c(15)) or (carry(14) and (d(15) xor c(15)));
		  
        return chk;
 end ret_chksum;
	 
   

signal data_register : STD_LOGIC_VECTOR (15 downto 0);
signal inter_register: STD_LOGIC_VECTOR (31 downto 0);
signal output_register: STD_LOGIC_VECTOR (15 downto 0);
begin
	
	process(CLK, nRST)
	begin
		if (nRST = '0') then
			data_register <= X"0000";
			inter_register <= X"00000000";
			output_register <= X"0000";
		elsif (rising_edge(CLK)) then
			if (INIT = '1') then
				inter_register <= X"00000000";
				data_register <= X"0000";
				output_register <= X"0000";
			else
				if (REQ = '1') then
					output_register <= ret_chksum(inter_register);
					if (SELB = '0') then
						CHKSUM <= output_register(15 downto 8);
					else
						CHKSUM <= output_register(7 downto 0);
					end if;
				else
					if (D_VALID = '1') then
						if (SELB = '0') then
							data_register(15 downto 8) <= DATA;
						else
							data_register(7 downto 0) <= DATA;
						end if;
					end if;
					if (CALC = '1') then
						inter_register <= cal_chksum(data_register, inter_register);
					end if;
				end if;
			end if;
		end if;

	end process;

end Behavioral;

