----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2026 16:34:45
-- Design Name: 
-- Module Name: uart_rx_tb - Behavioral
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

entity uart_rx_tb is
--  Port ( );
end uart_rx_tb;

architecture test of uart_rx_tb is
signal clk : std_logic;
signal rst : std_logic;
signal rx_data_in : std_logic;
signal rx_data_out : std_logic_vector (7 downto 0);

constant CLK_PERIOD : time := 10 ns;
constant BIT_PERIOD : time := 104166 ns; -- for 9600 baud

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

uart_rx_inst : entity work.uart_rx(Behavioral)
    port map(
        clk => clk,
        rst => rst,
        rx_data_in => rx_data_in,
        rx_data_out => rx_data_out
    );
    
process
begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;
    
    -- start bit
    rx_data_in <= '0';
    wait for BIT_PERIOD;
    
    -- sending 10110110
    for i in 0 to 7 loop
        if i mod 3 = 0 then rx_data_in <= '0'; else rx_data_in <= '1'; end if;
        wait for BIT_PERIOD;
    end loop;
    
    -- stop bit
    rx_data_in <= '1';
    wait for BIT_PERIOD;
    
    assert(rx_data_out = "10110110")
        report "receiving wrong data"
        severity failure;
    
    report "simulation complete";
    wait;
    
end process;

end test;
