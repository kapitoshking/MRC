-- Модульный сумматор
--
-- Авторы: Назаров Антон, Дерябин Максим, Бабенко Михаил
-- Научный руководитель: Червяков Николай Иванович
-- Дата: 13.11.2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity Add_mod is
	 Generic (
		constant p : unsigned(mod_bc-1 downto 0)									-- модуль
	 );
    Port ( 
		A       : in   unsigned (p'length - 1 downto 0);			 
		B       : in   unsigned (p'length - 1 downto 0);			
		Sum_mod : out  unsigned (p'length - 1 downto 0)
	 );
end Add_mod;

architecture Behavioral of Add_mod is

	constant p_BC : natural := p'length;	-- разрядность модуля
	
	-- вспомогательные константы 
    constant U1 :  signed (p_BC downto 0) := (p_BC => '1', others => '0');
	constant U : unsigned (p_BC - 1 downto 0) := resize(unsigned(U1 - signed(p)), p_BC);
	
	-- временные сигналы
	signal  s1 : unsigned (p_BC downto 0) := (others => '0');
	signal  s2 : unsigned (p_BC downto 0) := (others => '0');
	
begin

	s1 <= unsigned('0'&A) + unsigned(B);
	
	s2 <= s1+U;
	
	Sum_mod <= s1(p_BC - 1 downto 0) WHEN s2(p_BC)='0' ELSE s2(p_BC - 1 downto 0);
	
end Behavioral;
