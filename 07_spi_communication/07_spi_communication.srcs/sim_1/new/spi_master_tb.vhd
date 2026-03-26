----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2026 18:08:15
-- Design Name: 
-- Module Name: spi_master_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_master_tb is
--  Port ( );
end spi_master_tb;

architecture test of spi_master_tb is
signal clk : std_logic;
signal rst : std_logic;
signal busy : std_logic;
signal start_tx : std_logic;
signal tx_data : std_logic_vector(7 downto 0);
signal rx_data : std_logic_vector(7 downto 0);
signal sclk : std_logic;
signal ss : std_logic;
signal mosi : std_logic;
signal miso : std_logic;

constant CLK_PERIOD : time := 10 ns; -- 100Mhz
constant DATA_OUT : std_logic_vector(7 downto 0) := "10100101";
constant DATA_IN : std_logic_vector(7 downto 0) := "11101001";

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

spi_master_inst : entity work.spi_master(Behavioral)
    port map(
        clk => clk,
        rst => rst,
        busy => busy,
        start_tx => start_tx,
        tx_data => tx_data,
        rx_data => rx_data,
        sclk => sclk,
        ss => ss,
        mosi => mosi,
        miso => miso
    );
    
process
begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;

    tx_data <= DATA_OUT;
    assert(sclk = '0') severity failure;
    assert(busy = '0') severity failure;
    assert(ss = '1') severity failure;

    start_tx <= '1';
    wait until rising_edge(clk);
    start_tx <= '0';

    wait until rising_edge(sclk);
    for i in 0 to 7 loop
        miso <= DATA_IN(7-i);
        assert (mosi = DATA_OUT(7-i)) severity failure;
        assert(busy = '1') severity failure;
        assert(ss = '0') severity failure;
        if i < 7 then
            wait until rising_edge(sclk);
        end if;
    end loop;

    wait until busy = '0';
    assert(ss = '1') severity failure;
    assert(rx_data = DATA_IN);

    report "simulation complete";
    wait;   
end process;

end test;
