library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU_TB is
end entity CPU_TB;

architecture test of CPU_TB is

    component CPU_Top is
        port (
            clk : in std_logic;
            rst : in std_logic;
            dbg_pc : out std_logic(7 downto 0);
            dbg_r1 : out std_logic(7 downto 0);
            dbg_r2 : out std_logic(7 downto 0);
            dbg_alu : out std_logic(7 downto 0);
            halted : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal dbg_pc : std_logic_vector(7 downto 0);
    signal dbg_r1 : std_logic_vector(7 downto 0);
    signal dbg_r2 : std_logic_vector(7 downto 0);
    signal dbg_alu : std_logic_vector(7 downto 0);
    signal halted_tb : std_logic;

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

begin

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    DUT : CPU_Top
        port map (
            clk => clk,
            rst => rst,
            dbg_pc => dbg_pc,
            dbg_r1 => dbg_r1,
            dbg_r2 => dbg_r2,
            dbg_alu => dbg_alu,
            halted => halted_tb
        );

    process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '0';

        wait for CLK_PERIOD * 20;

        assert halted_tb = '1' severity warning;

        report "simulation complete";
        wait;
    end process;

end architecture test;
