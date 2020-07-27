library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity R_code_64_bit_MRC_TB is
end R_code_64_bit_MRC_TB;

architecture Behavioral of R_code_64_bit_MRC_TB is
    Component R_code_64_bit_MRC
        Port (input : in mod_type;
              output : out unsigned(num_bc-1 downto 0));
    end component;
    
    signal input : mod_type;
    signal output : unsigned(num_bc-1 downto 0);
begin
    uut: R_code_64_bit_MRC
    Port map (input => input,
              output => output);
    -- Stimulus process
    stim_proc: process
    begin        
        -- hold reset state for 100 ns.
          
        input <= ("011111111111111111111111111111111",
				  "000000000000000000000000000000000",
				  "000000000000000000000000000001000",
				  "000000000000000000000000000011000");
        wait for 100 ns;      
        wait;
    end process;
end Behavioral;