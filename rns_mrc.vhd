library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity rns_mrc is
    Generic (constant proj : natural);
    Port (input_rns : in set_mod_type;
          output_mrc : out set_mod_type);
end rns_mrc;

architecture Behavioral of rns_mrc is
    signal b_loc : b_loc_type(1 to (k+1)*k/2);
    type mrc_tree is array (1 to k) of unsigned(2*mod_bc+k-2 downto 0);
    signal mrc_temp : mrc_tree;
    type carry_type is array (1 to k-1) of unsigned(2*mod_bc+k-2 downto 0);
    signal carry : carry_type;
    type mrc_temp_1_type is array (2 to k) of unsigned(2*mod_bc+k-2 downto 0);
    signal mrc_temp_1 : mrc_temp_1_type;
    
    Component add_tree 
        Generic (dinamic_count : natural);
        Port (input : in b_loc_type;
              output : out unsigned(2*mod_bc+k-2 downto 0));
    end component;
    
    Component div_mod
        Generic (modul : unsigned(mod_bc-1 downto 0));
        Port (num : in unsigned(2*mod_bc+k-2 downto 0);
              quot : out unsigned(2*mod_bc+k-2 downto 0);
              remain : out unsigned(mod_bc-1 downto 0));
    end component;
    
    Component Mod_p_mrc
        Generic (p : unsigned(mod_bc-1 downto 0);
                 B : natural;
                 X_bc : natural);
        Port (X : in   unsigned(X_bc - 1 downto 0);
              X_mod_p : out  unsigned(p'length - 1 downto 0));
    end component;
       
begin

    b_mul_i : for j in 1 to k generate
    begin
        b_mul_j : for kk in j to k generate
        begin
            --b_loc(j+k*(k-1)/2) <= resize(b(proj)((count-1)*(j-1)-j*(j-1)/2+k),2*mod_bc+count-1)*input_rns(k);
            b_loc(j+kk*(kk-1)/2) <= resize(b(proj)(k*(j-1)-j*(j-1)/2+kk)*input_rns(j-1), b_loc(j+kk*(kk-1)/2)'length);
        end generate b_mul_j;
    end generate b_mul_i;
    
    mrc_temp(1) <= resize(b_loc(1),mrc_temp(1)'length);
    sum_tree : for j in 2 to k generate 
    begin
 --       b_loc_dinamic : for k in 1 to j generate 
 --       begin
 --           b_loc_tree(j)(k) <= b_loc(j*(j-1)/2+k); 
 --       end generate b_loc_dinamic;
        tree : add_tree 
            Generic map (dinamic_count => j)
            Port map (input => b_loc(j*(j-1)/2+1 to j*(j-1)/2+j),--b_loc_tree(j)
                      output => mrc_temp(j));     
    end generate sum_tree;
       
    mrc_last_1 : div_mod 
        Generic map (modul => m_proj(proj)(0))
        Port map (num => mrc_temp(1),
                  quot => carry(1),
                  remain => output_mrc(0));
                  
        mrc_temp_1(2) <= mrc_temp(2) + carry(1);
       
    carry_out : for i in 2 to k-1 generate 
        begin
            mrc_last : div_mod 
                Generic map (modul => m_proj(proj)(i-1))
                Port map (num => mrc_temp_1(i),
                          quot => carry(i),
                          remain => output_mrc(i-1));
                          
                mrc_temp_1(i+1) <= mrc_temp(i+1) + carry(i);
    end generate carry_out;
    
    mrc_last_count_1 : Mod_p_mrc 
        Generic map (p => m_proj(proj)(k-1),
                     B => 4,
                     X_bc => 2*mod_bc+k-1)
        Port map (X => mrc_temp_1(k),
                  X_mod_p => output_mrc(k-1));  

end Behavioral;