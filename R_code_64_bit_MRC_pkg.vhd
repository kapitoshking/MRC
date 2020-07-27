library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
--[[4294967296],[4294967297],[4294967299],[4294967301]]
package R_code_64_bit_MRC_pkg is

	constant count : natural := 4;
	constant mod_bc : natural := 33;
	constant num_bc : natural := 64;
    constant f : natural := 3; -- количество проекций
    constant k : natural := 2; -- количество рабочих оснований
    constant t : unsigned(count-1 downto 0) := "0001"; -- количество исправляемых ошибок
    type mod_type is array (0 to count-1) of unsigned(mod_bc-1 downto 0);
    type hd_type is array (0 to f-1) of unsigned(count-1 downto 0);
    type array_hd_type is array (0 to count-1) of unsigned(0 downto 0);
    type set_mod_type is array (0 to k-1) of unsigned(mod_bc-1 downto 0);
    type array_set_mod_type is array (0 to f-1) of set_mod_type;
--    type set_mod_type_rec is array (0 to k-2) of unsigned((k-1)*mod_bc-1 downto 0);
--    type array_set_mod_type_rec is array (0 to f-1) of set_mod_type_rec;
    type array_set_mod_type_rec is array (0 to f-1) of unsigned((k-1)*mod_bc-1 downto 0);
    type array_mod_type is array (0 to f-1) of mod_type;
    type proj_type is array (0 to f-1) of unsigned(k*mod_bc-1 downto 0);
    type basis_type is array (1 to (k+1)*k/2) of unsigned(mod_bc-1 downto 0);
    type array_basis_type is array (0 to f-1) of basis_type;
    type b_loc_type is array (natural range <>) of unsigned(2*mod_bc-1 downto 0);
    type rec_type is array (1 to k) of unsigned(k*mod_bc-1 downto 0);
    constant M_work : unsigned(k*mod_bc-1 downto 0) := "010000000000000000000000000000000100000000000000000000000000000000";

    constant m : mod_type := ("100000000000000000000000000000000",
                              "100000000000000000000000000000001",
                              "100000000000000000000000000000011",
                              "100000000000000000000000000000101");

	constant m_proj : array_set_mod_type := (
         ("100000000000000000000000000000000","100000000000000000000000000000001"),
         ("100000000000000000000000000000001","100000000000000000000000000000011"),
         ("100000000000000000000000000000011","100000000000000000000000000000101")
         );

    constant mod_mrc : array_set_mod_type_rec := (
        ("100000000000000000000000000000000"),
        ("100000000000000000000000000000001"),
        ("100000000000000000000000000000011")
        );
                                  
    constant b : array_basis_type := (
         ("000000000000000000000000000000001","000000000000000000000000000000001","100000000000000000000000000000000"),
         ("000000000000000000000000000000001","010000000000000000000000000000010","010000000000000000000000000000001"),
         ("000000000000000000000000000000001","010000000000000000000000000000011","010000000000000000000000000000010")
         );

end R_code_64_bit_MRC_pkg;

package body R_code_64_bit_MRC_pkg is

end R_code_64_bit_MRC_pkg;
