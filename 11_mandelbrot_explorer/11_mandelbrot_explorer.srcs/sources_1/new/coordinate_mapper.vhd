library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mandelbrot_pkg.all;

entity coordinate_mapper is
    Port (
        pixel_x : in unsigned(9 downto 0);
        pixel_y : in unsigned(9 downto 0);
        scaled_x : out signed(27 downto 0);
        scaled_y : out signed(27 downto 0)
    );
end coordinate_mapper;

architecture Behavioral of coordinate_mapper is
    constant TARGET_X : real := -0.75;
    constant TARGET_Y : real := 0.1;

    constant ZOOM_WIDTH : real := 0.5; 
    constant ZOOM_HEIGHT : real := ZOOM_WIDTH * (V_PIXELS / H_PIXELS);

    constant X_START_REAL : real := TARGET_X - (ZOOM_WIDTH / 2.0);
    constant Y_START_REAL : real := TARGET_Y - (ZOOM_HEIGHT / 2.0);

    constant X_START : signed(27 downto 0) := to_signed(integer(X_START_REAL * real(SCALE)), 28);
    constant Y_START : signed(27 downto 0) := to_signed(integer(Y_START_REAL * real(SCALE)), 28);

    constant STEP : signed(27 downto 0) := to_signed(integer((ZOOM_WIDTH / H_PIXELS) * real(SCALE)), 28);

begin
    
    scaled_x <= X_START + resize(signed('0' & std_logic_vector(pixel_x)) * STEP, 28);
    scaled_y <= Y_START + resize(signed('0' & std_logic_vector(pixel_y)) * STEP, 28);

end Behavioral;
