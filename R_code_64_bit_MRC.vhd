library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity R_code_64_bit_MRC is
    Port (input : in mod_type;
          output : out unsigned(num_bc-1 downto 0));
end R_code_64_bit_MRC;

architecture Behavioral of R_code_64_bit_MRC is
    signal num_rns : array_set_mod_type;
    signal num_mrc : array_set_mod_type;
    signal proj_rec : proj_type;
    signal hd_projections : hd_type;
    signal projections : unsigned(f-1 downto 0);
    signal proj_rns : array_mod_type;
    signal projection : natural;
    
    Component rns_mrc
        Generic (proj : natural);
        Port (input_rns : in set_mod_type;
              output_mrc : out set_mod_type);
    end component;
    
    Component recovery
        Generic (proj : natural);
        Port (input_mrc : in set_mod_type;
              output : out unsigned(k*mod_bc-1 downto 0));
    end component;

    Component Mod_p
        Generic (num_mod : natural);
        Port (X : in unsigned(k*mod_bc-1 downto 0);
              X_mod_p : out unsigned(mod_bc-1 downto 0));
    end component;

    Component HD
        Port (input : in mod_type;
              input_proj_rns : in mod_type;
              output_hd : out unsigned);
    end component;

    Component select_projection
        Port (proj : in unsigned(f-1 downto 0);
              output : out natural);
    end component;
    
begin

    localization_proj : for i in 0 to f-1 generate
    begin
        rns_i : for j in 0 to k-1 generate
        begin
            num_rns(i)(j) <= input(i+j);
        end generate rns_i;
    end generate localization_proj;
    
    calc_proj_mrc : for i in 0 to f-1 generate
    begin
        rnsmrc : rns_mrc
             Generic map (proj => i)
             Port map (input_rns => num_rns(i),
                       output_mrc => num_mrc(i));

    end generate calc_proj_mrc;

    calc_proj : for i in 0 to f-1 generate
    begin
        rec : recovery
             Generic map (proj => i)
             Port map (input_mrc => num_mrc(i),
                       output => proj_rec(i));

    end generate calc_proj;
 
    projection_rns : for i in 0 to f-1 generate
    begin
        proj_1 : for j in 0 to i-1 generate
        begin
        Modp : Mod_p
             Generic map (num_mod => j)
             Port map (X => proj_rec(i),
                       X_mod_p => proj_rns(i)(j));
        end generate proj_1;
        
        proj_i : for j in i to i+k-1 generate
        begin
            proj_rns(i)(j) <= input(j);
        end generate proj_i;
        
        proj_n : for j in i+k to count-1 generate
        begin
        Modp : Mod_p
             Generic map (num_mod => j)
             Port map (X => proj_rec(i),
                       X_mod_p => proj_rns(i)(j));
        end generate proj_n;
    end generate projection_rns;
    
    hd_proj : for i in 0 to f-1 generate
    begin
       hdproj : HD
             Port map (input => input,
                       input_proj_rns => proj_rns(i),
                       output_hd => hd_projections(i));
    end generate hd_proj;

    process (proj_rec, hd_projections)
    variable pr : unsigned(f-1 downto 0);
    begin
        for i in 0 to f-1 loop
           if (proj_rec(i) < M_work) and (hd_projections(i) <= t) then 
               pr(i) := '1';
           else
               pr(i) := '0';
           end if;
        end loop;
    projections <= pr;
    end process;

    select_proj : select_projection
            Port map (proj => projections,
                      output => projection);
                      
    output <= resize(proj_rec(projection),num_bc);

end Behavioral;