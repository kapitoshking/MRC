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

entity Mod_p is
	 Generic (constant num_mod : natural);
     Port (X       : in   unsigned(k*mod_bc-1 downto 0);		-- вход X
           X_mod_p : out  unsigned(mod_bc-1 downto 0)  -- выход: остаток X по модулю p
     );
end Mod_p;

architecture Behavioral of Mod_p is

	-- исходные константы разрядностей
	constant B      : natural := 4;
	constant p      : unsigned(mod_bc-1 downto 0) := m(num_mod);
	constant X_bc   : natural := k*mod_bc;
	constant p_bc   : natural := mod_bc;	-- разрядность модуля
	constant pow2_B : natural := to_integer(SHIFT_LEFT(to_unsigned(1, B+1), B));	-- количество чисел в одном разряде


	-- функция для вычисления количества частей после разбиения 
	function calc_dc return natural is
		variable residue : natural;
	begin
		residue := X_bc mod B;
		if (residue = 0) then
			return X_bc / B;
		else
			return X_bc / B + 1;
		end if;
	end calc_dc;
	
	-- количество элементов разбиения (входов первого слоя)
	constant dc   : natural := calc_dc;							
	
	-- блок объявления типов данных для формирования таблицы остатков 
	type LUT_type is array (0 to dc - 1) of unsigned (p_bc - 1 downto 0); 
	type array_LUT_type is array (0 to pow2_B - 1) of LUT_type;
	
	-- формирование таблицы остатков по модулю p произведений числа l
	-- на все возможные коэффициенты частей разбиения (2^i)
	function Tabl (l: natural; dc: natural) return LUT_type is
		variable result : LUT_type; 
		variable shift  : natural;
	begin
		for i in 0 to dc-1 loop 
			shift := B * i; 
			result(i) := SHIFT_LEFT(to_unsigned(l, dc*B), shift) mod p;
		end loop;
		return result;
	end Tabl;
	
	-- формирование таблицы значений Tabl для всех возможных l
	function TablOfTabl(dc: natural) return array_LUT_type is
		variable result : array_LUT_type;
	begin
		for i in 0 to pow2_B-1 loop 
			result(i) := Tabl(i, dc);
		end loop;
		return result;
	end TablOfTabl;
	
	-- количество элементов на входе слоя с номером layer_num
	function LayerInputSize (layer_num: natural; digit_count: natural) return natural is
		variable result : natural;
	begin
		result := digit_count;
		for i in 2 to layer_num loop
			result := (result / 2) + (result mod 2);
		end loop;
		return result;
	end LayerInputSize;
	
	-- начальная позиция элементов слоя layer_num в в общем массиве сигналов
	function LayerStart (layer_num: natural; digit_count: natural) return natural is
		variable result : natural;
	begin
		result := 0;
		for i in 1 to layer_num-1 loop
			result := result + LayerInputSize(i, digit_count);
		end loop;
		return result;
	end LayerStart;
	
	-- количество слоев - натуральный логарифм от количества элементов первого слоя (разбиения)
	-- с округлением вверх
	function LayersCount(digit_count: in natural) return natural is
		variable res : natural;
		variable vn  : unsigned(31 downto 0);	-- число, учитывающее границы типа natural
	begin
		res := 0;
		
		vn := to_unsigned(digit_count-1, 32);		-- digit_count-1 чтобы верно считать log(2^t)
		
		-- считаем количество бит в числе vn
		while to_integer(vn) /= 0 loop
			res := res + 1;
			vn := vn srl 1;
		end loop;
		
		return res;
	end function LayersCount;
	
	-- общее количество элементов на всех слоях, включая выходной
	function AllLayersSize(layers_count, digit_count : in natural) return natural is
		variable res : natural;
	begin
		res := 0;
		
		-- складываются количества элеметов на всех слоях плюс выходной элемент
		for ln in 1 to layers_count+1 loop
			res := res + LayerInputSize(ln, digit_count);
		end loop;
		
		return res;
	end function AllLayersSize;
	
	
	-- блок констант, требуемых в вычислениях
	
	constant LUT  : array_LUT_type := TablOfTabl(dc);		-- таблица констант остатков от деления
	
	constant lc : natural := LayersCount(dc);					-- количество слоев
	
	constant als : natural := AllLayersSize(lc, dc);		-- количество элементов на всех слоях
	
	-- массив элементов, требуемых в вычислениях на всех слоях
	-- связывает предыдущий и следующий слои
	-- является массивом, формируемым последовательно из выходов каждого слоя
	type digits_array is array (0 to als-1) of unsigned(p_bc-1 downto 0); 
	signal digits : digits_array;
	
	-- всременный сигнал, изменяющий разрядность входного сигнала кратно B
	signal new_X : unsigned( B * dc - 1 downto 0);
	
	
	-- Подключение компонетна сдл модульного сложения двух чисел
	COMPONENT Add_mod
	GENERIC (
		p : unsigned
	);
	PORT(
		A : IN  unsigned (p_bc-1 downto 0);
		B : IN  unsigned (p_bc-1 downto 0);          
		Sum_mod : OUT unsigned (p_bc-1 downto 0)
	);
	END COMPONENT;
	
begin

	-- копирование входного сигнала с изменением разрядности
	new_X <= resize(unsigned(X), B * dc);
	
	-- уровень 1: разбиение числа на блоки по B бит
	level_1: for i in 0 to dc-1 generate
	begin
		digits(i) <= LUT(to_integer(new_X(B*(i+1)-1 downto B*i)))(i);
	end generate level_1;
	
	-- генерирование последовательности слоев
	layers: for i in 1 to lc generate
   begin
		
		-- уровень 2: сложение элементов бинарным сдваиванием
		level_2: for j in 0 to LayerInputSize(i,dc)/2 - 1  generate
		begin
			Add_mod_inst: Add_mod 
			GENERIC MAP (
				p => p
			)
			PORT MAP(
				A => digits(LayerStart(i, dc) + j),
				B => digits(LayerStart(i, dc) + LayerInputSize(i,dc) - 1 - j),
				Sum_mod => digits(LayerStart(i + 1, dc) + j)
			);
		end generate level_2;
		
		-- перенос несдвоенного элемента в случае нечетного числа элеменов на слое
		if_odd: if ((LayerInputSize(i,dc) mod 2) = 1) generate
			digits(LayerStart(i+1,dc) + LayerInputSize(i+1,dc)-1) <= digits(LayerStart(i,dc) + LayerInputSize(i,dc)/2);
		end generate if_odd;
		
	end generate layers;

	-- формирование выходного сигнала
	X_mod_p <= unsigned(digits(AllLayersSize(lc, dc)-1));
	
end Behavioral;