library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_controller_tb is
--  Port ( );
end spi_controller_tb;

architecture test of spi_controller_tb is
signal clk : std_logic;
signal rst : std_logic;
signal start_tx : std_logic;
signal busy : std_logic;
signal tx_data : std_logic_vector(7 downto 0);
signal rx_data : std_logic_vector(7 downto 0);

constant CLK_PERIOD : time := 10 ns; -- 100Mhz
constant DATA : std_logic_vector(7 downto 0) := "10100101";

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

spi_controller_inst : entity work.spi_controller(Structural)
    port map(
        clk => clk,
        rst => rst,
        start_tx => start_tx,
        busy => busy,
        tx_data => tx_data,
        rx_data => rx_data
    );
    
process
begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;
    
    tx_data <= DATA;
    
    -- first transaction
    start_tx <= '1';
    wait until busy = '1';
    start_tx <= '0';
    wait until busy = '0';
    
    assert rx_data = "00000000";
    wait for 10.1 ms; -- wait for debouncer
    
    -- second transaction
    start_tx <= '1';
    wait until busy = '1';
    start_tx <= '0';
    wait until busy = '0';
    
    assert rx_data = DATA;
    
    report "simulation complete";
    wait;
    
end process;

end test;
