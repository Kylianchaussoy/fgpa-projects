library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

    -- Q4.24 notation
    constant SCALE_REAL : real := 16777216.0;
    constant INIT_TARGET_X : signed(27 downto 0) := to_signed(integer(0.0 * SCALE_REAL), 28);
    constant INIT_TARGET_Y : signed(27 downto 0) := to_signed(integer(0.0 * SCALE_REAL), 28);
    constant INIT_ZOOM : signed(27 downto 0) := to_signed(integer(3.5 * SCALE_REAL), 28);
    constant INV_H_PIXELS : signed(27 downto 0) := to_signed(integer((1.0 / 640.0) * SCALE_REAL), 28);
    constant MIN_ZOOM_WIDTH : signed := to_signed(4096, 28);
    constant MAX_ZOOM_WIDTH : signed := to_signed(67108864, 28);

end package mandelbrot_pkg;
