library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mandelbrot_pkg.all;

entity coordinate_mapper is
    Port (
        clk_25 : in std_logic;
        pan_right : in std_logic;
        pan_left : in std_logic;
        pan_down : in std_logic;
        pan_up : in std_logic;
        zoom : in std_logic;
        zoom_mode : in std_logic;
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        scaled_x : out signed(27 downto 0);
        scaled_y : out signed(27 downto 0)
    );
end coordinate_mapper;

architecture Behavioral of coordinate_mapper is
    signal target_x : signed(27 downto 0) := INIT_TARGET_X;
    signal target_y : signed(27 downto 0) := INIT_TARGET_Y;
    signal zoom_width : signed(27 downto 0) := INIT_ZOOM;

    signal x_start : signed(27 downto 0);
    signal y_start : signed(27 downto 0);
    signal step_size : signed(27 downto 0);

    signal step_calc : signed(55 downto 0);
    signal pan_amount : signed(27 downto 0);

begin

    x_start <= target_x - shift_right(zoom_width, 1);
    y_start <= target_y - (shift_right(zoom_width, 2) + shift_right(zoom_width, 3));
    step_calc <= zoom_width * INV_H_PIXELS;
    step_size <= resize(shift_right(step_calc, 24), 28);
    
    scaled_x <= X_START + resize(signed('0' & std_logic_vector(pixel_x)) * step_size, 28);
    scaled_y <= Y_START + resize(signed('0' & std_logic_vector(pixel_y)) * step_size, 28);

    pan_amount <= shift_right(zoom_width, 4);

    process(clk_25)
    begin
        if rising_edge(clk_25) then
            
            if pan_right = '1' then
                target_x <= target_x + pan_amount;
            elsif pan_left = '1' then
                target_x <= target_x - pan_amount;
            end if;

            if pan_down = '1' then
                target_y <= target_y + pan_amount;
            elsif pan_up = '1' then
                target_y <= target_y - pan_amount;
            end if;

            if zoom = '1' and zoom_mode = '0' then
                if zoom_width > MIN_ZOOM_WIDTH then
                    zoom_width <= zoom_width - shift_right(zoom_width, 3);
                end if;
                
            elsif zoom = '1' and zoom_mode = '1' then
                if zoom_width < MAX_ZOOM_WIDTH then
                    zoom_width <= zoom_width + shift_right(zoom_width, 3);
                end if;
            end if;

        end if;
    end process;


end Behavioral;
