library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.R_code_64_bit_MRC_pkg.ALL;

entity add_tree_rec is
    Generic (constant dinamic_count : natural);
    Port (input : in rec_type;
          output : out unsigned(k*mod_bc-1 downto 0));
end add_tree_rec;

architecture Behavioral of add_tree_rec is

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
        variable vn  : unsigned(31 downto 0);    -- число, учитывающее границы типа natural
    begin
        res := 0;
        
        vn := to_unsigned(digit_count-1, 32);        -- digit_count-1 чтобы верно считать log(2^t)
        
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
    
    constant lc : natural := LayersCount(dinamic_count);					-- количество слоев
    
    constant als : natural := AllLayersSize(lc, dinamic_count);        -- количество элементов на всех слоях
    
    -- массив элементов, требуемых в вычислениях на всех слоях
    -- связывает предыдущий и следующий слои
    -- является массивом, формируемым последовательно из выходов каждого слоя
    type digits_array is array (0 to als-1) of unsigned(k*mod_bc-1 downto 0); 
    signal digits : digits_array;
begin
    
	level_1: for i in 0 to dinamic_count-1 generate
	begin
		digits(i) <= resize(input(i+1),digits(i)'length);
	end generate level_1;
	
	-- генерирование последовательности слоев
    layers: for i in 1 to lc generate
    begin
        
        -- уровень 2: сложение элементов бинарным сдваиванием
        level_2: for j in 0 to LayerInputSize(i,dinamic_count)/2 - 1  generate
        begin
            digits(LayerStart(i + 1, dinamic_count) + j) <= resize(digits(LayerStart(i, dinamic_count) + j) + digits(LayerStart(i, dinamic_count) + LayerInputSize(i,dinamic_count) - 1 - j),digits(LayerStart(i + 1, dinamic_count) + j)'length);
        end generate level_2;
        
        -- перенос несдвоенного элемента в случае нечетного числа элеменов на слое
        if_odd: if ((LayerInputSize(i,dinamic_count) mod 2) = 1) generate
            digits(LayerStart(i+1,dinamic_count) + LayerInputSize(i+1,dinamic_count)-1) <= resize(digits(LayerStart(i,dinamic_count) + LayerInputSize(i,dinamic_count)/2),digits(LayerStart(i+1,dinamic_count) + LayerInputSize(i+1,dinamic_count)-1)'length);
        end generate if_odd;
        
    end generate layers;
    
    -- формирование выходного сигнала
    output <= resize(digits(AllLayersSize(lc, dinamic_count)-1),output'length);

end Behavioral;