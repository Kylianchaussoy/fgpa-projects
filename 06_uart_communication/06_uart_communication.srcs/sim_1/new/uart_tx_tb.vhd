----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2026 17:06:00
-- Design Name: 
-- Module Name: uart_tx_tb - Behavioral
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

entity uart_tx_tb is
--  Port ( );
end uart_tx_tb;

architecture test of uart_tx_tb is
signal clk : std_logic;
signal rst : std_logic;
signal tx_start :  std_logic;
signal tx_data_in : std_logic_vector (7 downto 0);
signal tx_data_out : std_logic;

constant CLK_PERIOD : time := 10 ns;
constant BIT_PERIOD : time := 104166 ns; -- for 9600 baud
constant DATA : std_logic_vector (7 downto 0) := "10110110";

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

uart_tx_inst : entity work.uart_tx(Behavioral)
    port map(
        clk => clk,
        rst => rst,
        tx_start => tx_start,
        tx_data_in => tx_data_in,
        tx_data_out => tx_data_out
    );
    
process
begin
    rst <= '1';
    tx_start <= '0';
    tx_data_in <= (others => '0');
    wait for 100 ns;
    
    rst <= '0';
    wait for BIT_PERIOD; -- clearing internal flag
    
    wait until rising_edge(clk);
    tx_data_in <= DATA;
    tx_start <= '1';
    wait until rising_edge(clk);
    tx_start <= '0';
    
    wait until falling_edge(tx_data_out); 
    -- wait for start bit to pass
    wait for BIT_PERIOD * 1.5;
    
    for i in 0 to 7 loop
        assert(tx_data_out = DATA(i))
            report "not sending the right data" severity failure;
        wait for BIT_PERIOD;
    end loop;
    
    assert (tx_data_out = '1')
        report "no stop bit" severity failure;
        
    report "simulation complete";
    wait;
    
end process;

end test;
