library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mandelbrot_pkg.all;

entity color_mapper is
    Port (
        iter_count : in unsigned(3 downto 0);
        done : in std_logic;
        rgb : out std_logic_vector(11 downto 0)
    );
end color_mapper;

architecture Behavioral of color_mapper is
begin
    process(iter_count, done)
    begin
        if done = '0' then
            rgb <= BLACK;
        else
            case iter_count is
                when x"0" => rgb <= DARK_BLUE;
                when x"1" => rgb <= MID_BLUE;
                when x"2" => rgb <= LIGHT_BLUE;
                when x"3" => rgb <= CYAN;
                when x"4" => rgb <= GREEN;
                when x"5" => rgb <= YELLOW_GREEN;
                when x"6" => rgb <= YELLOW;
                when x"7" => rgb <= ORANGE;
                when x"8" => rgb <= RED_ORANGE;
                when x"9" => rgb <= RED;
                when x"A" => rgb <= DARK_RED;
                when x"B" => rgb <= PURPLE;
                when x"C" => rgb <= MAGENTA;
                when x"D" => rgb <= PINK;
                when x"E" => rgb <= WHITE;
                when x"F" => rgb <= GREY;
                when others => rgb <= BLACK;
            end case;
        end if;
    end process;

end Behavioral;
