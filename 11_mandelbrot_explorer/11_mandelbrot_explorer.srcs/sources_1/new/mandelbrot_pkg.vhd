library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package mandelbrot_pkg is

    subtype color_4b_t is std_logic_vector(11 downto 0);
    constant DARK_BLUE : color_4b_t := x"002";
    constant MID_BLUE : color_4b_t := x"008";
    constant LIGHT_BLUE : color_4b_t := x"04F";
    constant CYAN : color_4b_t := x"0AF";
    constant GREEN : color_4b_t := x"2F8";
    constant YELLOW_GREEN : color_4b_t := x"8F0";
    constant YELLOW : color_4b_t := x"FF0";
    constant ORANGE : color_4b_t := x"FA0";
    constant RED_ORANGE : color_4b_t := x"F40";
    constant RED : color_4b_t := x"D00";
    constant DARK_RED : color_4b_t := x"800";
    constant PURPLE : color_4b_t := x"808";
    constant MAGENTA : color_4b_t := x"C0C";
    constant PINK : color_4b_t := x"F8F";
    constant WHITE : color_4b_t := x"FFF";
    constant GREY : color_4b_t := x"888";
    constant BLACK : color_4b_t := x"000";

    -- for Q4.24 notation
    constant FRAC_BITS : integer := 24;
    constant SCALE : integer := 2**FRAC_BITS;

    constant H_PIXELS : real := 640.0;
    constant V_PIXELS : real := 480.0;

end package mandelbrot_pkg;
