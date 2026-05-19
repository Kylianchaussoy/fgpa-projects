library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mandelbrot_pkg.all;

entity mandelbrot_core is
    Generic (
        MAX_ITER : integer := 64;
        DATA_BITS : integer := 28
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        c_re : in signed(27 downto 0);
        c_im : in signed(27 downto 0);
        iter_count : out unsigned(6 downto 0);
        done : out std_logic
    );
end mandelbrot_core;

architecture Behavioral of mandelbrot_core is

    constant FOUR : signed(28 downto 0) := to_signed(integer(4.0 * SCALE_REAL), 29);

    type state_type is (IDLE, WAIT_MUL, CALC, FINISH);
    signal state : state_type := IDLE;

    signal z_re : signed(27 downto 0) := (others => '0');
    signal z_im : signed(27 downto 0) := (others => '0');
    signal count : unsigned(6 downto 0) := (others => '0');

    signal z_re_sq_reg : signed(27 downto 0) := (others => '0');
    signal z_im_sq_reg : signed(27 downto 0) := (others => '0');
    signal z_re_im_reg : signed(27 downto 0) := (others => '0');

    signal z_re_sq : signed(27 downto 0);
    signal z_im_sq : signed(27 downto 0);
    signal z_re_im : signed(27 downto 0);

    signal mag_sq  : signed(28 downto 0);

begin

    mul_re_sq : entity work.fixed_point_mul port map (a => z_re, b => z_re, result => z_re_sq);
    mul_im_sq : entity work.fixed_point_mul port map (a => z_im, b => z_im, result => z_im_sq);
    mul_re_im : entity work.fixed_point_mul port map (a => z_re, b => z_im, result => z_re_im);

    mag_sq <= resize(z_re_sq_reg, 29) + resize(z_im_sq_reg, 29);

    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            done <= '0';
            iter_count <= (others => '0');
            z_re <= (others => '0');
            z_im <= (others => '0');
            count <= (others => '0');
            z_re_sq_reg <= (others => '0');
            z_im_sq_reg <= (others => '0');
            z_re_im_reg <= (others => '0');

        elsif rising_edge(clk) then
            done <= '0';

            case state is

                when IDLE =>
                    if start = '1' then
                        z_re  <= (others => '0');
                        z_im  <= (others => '0');
                        count <= (others => '0');
                        state <= WAIT_MUL;
                    end if;

                when WAIT_MUL =>
                    z_re_sq_reg <= z_re_sq;
                    z_im_sq_reg <= z_im_sq;
                    z_re_im_reg <= z_re_im;
                    state <= CALC;

                when CALC =>
                    if mag_sq >= FOUR or count = to_unsigned(MAX_ITER, 7) then
                        iter_count <= count;
                        state <= FINISH;
                    else
                        z_re <= z_re_sq_reg - z_im_sq_reg + c_re;
                        z_im <= shift_left(z_re_im_reg, 1) + c_im;
                        count <= count + 1;
                        state <= WAIT_MUL;
                    end if;

                when FINISH =>
                    done <= '1';
                    state <= IDLE;

            end case;
        end if;
    end process;

end Behavioral;
