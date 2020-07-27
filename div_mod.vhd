library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity div_mod is
	Generic (
		constant modul : unsigned(mod_bc-1 downto 0)
	);
	Port (
		num    : in unsigned(2*mod_bc+k-2 downto 0);
		quot   : out unsigned(2*mod_bc+k-2 downto 0);
		remain : out unsigned(mod_bc-1 downto 0)
	);
end div_mod;

architecture Behavioral of div_mod is

	function getTopBit(x: unsigned) return integer is 
	begin
	 for J in x'RANGE loop
		if x(J)='1' then
		  return J;
		end if;
	 end loop;
	 return -1;
	end function getTopBit;

    constant topbit_I : integer := getTopBit(modul);
	
	-- this internal procedure computes UNSIGNED division
	-- giving the quotient and remainder.
	procedure DIVMOD (signal NUM : unsigned; signal XQUOT, XREMAIN: out UNSIGNED) is
	 variable TEMP: UNSIGNED(NUM'LENGTH downto 0);
	 variable QUOT: UNSIGNED(NUM'LENGTH-1 downto 0);
	 --alias DENOM: UNSIGNED(m(I)'LENGTH-1 downto 0) is m(I);
	 --variable TOPBIT: INTEGER;
	begin
	 TEMP := "0"&NUM;
	 QUOT := (others => '0');
	
	 assert topbit_I >= 0 report "DIV, MOD, or REM by zero" severity ERROR;

	 for J in NUM'LENGTH-(topbit_I+1) downto 0 loop
		if TEMP(topbit_I+J+1 downto J) >= "0"&modul(topbit_I downto 0) then
		  TEMP(topbit_I+J+1 downto J) := (TEMP(topbit_I+J+1 downto J))
				-("0"&modul(topbit_I downto 0));
		  QUOT(J) := '1';
		end if;
		assert TEMP(topbit_I+J+1)='0'
			 report "internal error in the division algorithm"
			 severity ERROR;
	 end loop;
	 XQUOT <= RESIZE(QUOT, XQUOT'LENGTH);
	 XREMAIN <= RESIZE(TEMP, XREMAIN'LENGTH);
	end DIVMOD;

begin

	DIVMOD(num, quot, remain);

end Behavioral;
