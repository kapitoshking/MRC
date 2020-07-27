library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity select_projection is
    Port (proj : in unsigned(f-1 downto 0);
          output : out natural);
end select_projection;

architecture Behavioral of select_projection is

	function getTopBit(x: unsigned) return natural is 
    begin
     for J in x'RANGE loop
        if x(J)='1' then
          return J;
        end if;
     end loop;
     return 0;
    end function getTopBit;
begin
    output <= getTopBit(proj);
end Behavioral;