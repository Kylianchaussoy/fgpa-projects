library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;


entity pipelined_cpu_tb is
--  Port ( );
end pipelined_cpu_tb;

architecture Behavioral of pipelined_cpu_tb is
    signal clk: std_logic;
    signal rst: std_logic;
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

begin

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    pipelined_cpu_inst: entity work.pipelined_cpu
        port map (
            clk => clk,
            rst => rst
        );

process
begin
    rst <= '0';
    report "CPU is running" severity note;
    wait;

end process;


end Behavioral;
