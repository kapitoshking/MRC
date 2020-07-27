library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity recovery is
    Generic (proj : natural);
    Port (input_mrc : in set_mod_type;
          output : out unsigned(k*mod_bc-1 downto 0));
end recovery;

architecture Behavioral of recovery is
    signal mrc_temp_rec : rec_type;
    
    Component add_tree_rec
        Generic (dinamic_count : natural);
        Port (input : in rec_type;
              output : out unsigned(k*mod_bc-1 downto 0));
    end component;
    
begin
    mrc_temp_rec(1) <= resize(input_mrc(0),mrc_temp_rec(1)'length);
    mul : for i in 2 to k generate
    begin
--        mrc_temp(i) <= resize(input_mrc(i-1)*mod_mrc(proj)(i-2),mrc_temp_rec(i)'length);
        mrc_temp_rec(i) <= resize(input_mrc(i-1)*mod_mrc(proj),mrc_temp_rec(i)'length);
    end generate mul;
    
    num_last : add_tree_rec 
        Generic map (dinamic_count => k)
        Port map (input => mrc_temp_rec,
                  output => output);

end Behavioral;
