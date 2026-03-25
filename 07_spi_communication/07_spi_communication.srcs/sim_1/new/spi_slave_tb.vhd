----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2026 18:08:15
-- Design Name: 
-- Module Name: spi_slave_tb - Behavioral
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

entity spi_slave_tb is
--  Port ( );
end spi_slave_tb;

architecture test of spi_slave_tb is
signal clk  : std_logic := '0';
signal rst  : std_logic := '0';
signal s_sclk : std_logic := '0';
signal sclk   : std_logic := '0'; 
signal mosi : std_logic := '0';
signal ss : std_logic := '1';
signal miso : std_logic;

constant CLK_PERIOD : time := 10 ns; -- 100Mhz
constant SCLK_PERIOD : time := 1000 ns; -- 1Mhz

constant DATA : std_logic_vector(7 downto 0) := "10100101";

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

sclk_process : process
begin
    s_sclk  <= '0';
    wait for SCLK_PERIOD/2;
    s_sclk  <= '1';
    wait for SCLK_PERIOD/2;
end process;

-- clock gating
sclk <= s_sclk when ss = '0' else '0';

spi_slave_inst : entity work.spi_slave(Behavioral)
    port map(
        clk => clk,
        rst => rst,
        sclk => sclk,
        mosi => mosi,
        ss => ss,
        miso => miso
    );
    
process
begin
    rst <= '1';
    ss <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;
    
    wait until falling_edge(s_sclk);
    ss <= '0';
    
    -- write data to slave
    for i in 0 to 7 loop
        mosi <= DATA(i);
        wait until falling_edge(s_sclk);
        wait for 5 ns;
        assert (miso = '0')
            severity failure;
    end loop;
    
    -- end transaction and trigger loopback
    ss <= '1';
    mosi <= '0';
    wait for 20 ns;
    
    wait until falling_edge(s_sclk);
    ss <= '0';
    
    -- read data from slave
    for i in 0 to 7 loop
        wait until rising_edge(s_sclk);
        wait for 5 ns;
        assert (miso = DATA(i))
            severity failure;
    end loop;
    
    ss <= '1';
    
    report "simulation complete";
    wait;
    
end process;

end test;
