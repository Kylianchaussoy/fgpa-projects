library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_mandelbrot_core is
end tb_mandelbrot_core;

architecture Behavioral of tb_mandelbrot_core is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal start : std_logic := '0';
    signal c_re : signed(27 downto 0) := (others => '0');
    signal c_im : signed(27 downto 0) := (others => '0');
    signal iter_count : unsigned(6 downto 0);
    signal done : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    uut : entity work.mandelbrot_core
        generic map (
            MAX_ITER  => 64,
            DATA_BITS => 28
        )
        port map (
            clk => clk,
            rst => rst,
            start => start,
            c_re => c_re,
            c_im => c_im,
            iter_count => iter_count,
            done => done
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus : process
    begin
        report "simulation started" severity note;
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        c_re <= to_signed(0, 28);
        c_im <= to_signed(0, 28);
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD;
        report "TEST 1 (0,0): iter_count = " & integer'image(to_integer(iter_count));
        wait for 100 ns;

        c_re <= to_signed(134217728, 28);
        c_im <= to_signed(0, 28);
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD;
        report "TEST 2 (2.0, 0): iter_count = " & integer'image(to_integer(iter_count));
        wait for 100 ns;

        c_re <= to_signed(-134217728, 28);
        c_im <= to_signed(0, 28);
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        wait for CLK_PERIOD;
        report "TEST 3 (-2.0, 0): iter_count = " & integer'image(to_integer(iter_count));
        wait for 100 ns;

        report "simulation complete" severity note;
        wait;
    end process;

end Behavioral;
