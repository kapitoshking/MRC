-- Вычисление остатка от деления числа X на модуль p
--	с настраиваемыми параметрами разрядности
--
-- Авторы: Назаров Антон, Дерябин Максим, Бабенко Михаил
-- Научный руководитель: Червяков Николай Иванович
-- Дата: 13.11.2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity HD is
     Port (input   : in   mod_type;
           input_proj_rns   : in   mod_type;
           output_hd : out  unsigned(count-1 downto 0)
     );
end HD;

architecture Behavioral of HD is

    signal ar_hd : array_hd_type;
    
    Component add_tree_hd
        Port (input : in array_hd_type;
              output : out unsigned(count-1 downto 0));
    end component;

begin

    arhd : for i in 0 to count-1 generate
    begin
        ar_hd(i) <= "1" WHEN input(i) /= input_proj_rns(i) ELSE "0";
    end generate arhd;
    
    addtreehd : add_tree_hd
        Port map (input => ar_hd,
                  output => output_hd);    

--    process (input, input_proj_rns)
--    variable sum_hd : unsigned(count-1 downto 0) := (others => '0');
--    variable incr : unsigned(count-1 downto 0) := (0 => '1', others => '0');
--    begin
--        for i in 0 to count-1 loop
--           if (input(i) /= input_proj_rns(i)) then 
--               sum_hd := sum_hd + incr;
--           end if;
--        end loop;
--    output_hd <= sum_hd;
--    end process;

end Behavioral;