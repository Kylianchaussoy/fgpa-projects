----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2026 17:44:54
-- Design Name: 
-- Module Name: uart_controller_tb - Behavioral
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

entity uart_controller_tb is
--  Port ( );
end uart_controller_tb;

architecture test of uart_controller_tb is
signal clk : std_logic;
signal rst : std_logic;
signal tx_enable : std_logic;
    
signal data_in : std_logic_vector(7 downto 0);
signal data_out : std_logic_vector(7 downto 0);
    
signal rx : std_logic;
signal tx : std_logic;

constant CLK_PERIOD : time := 10 ns;
constant BIT_PERIOD : time := 104166 ns; -- 9600 baud
constant DATA : std_logic_vector (7 downto 0) := "10110110";

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

uart_rx_inst : entity work.uart_controller(Structural)
    port map(
        clk => clk,
        rst => rst,
        tx_enable => tx_enable,
        data_in => data_in,
        data_out => data_out,
        rx => rx,
        tx => tx
    );
    
rx <= tx; -- loopback

process
begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    
    wait for BIT_PERIOD;
    data_in <= DATA;
    
    tx_enable <= '1';
    wait for 20 ms; -- natural button press
    tx_enable <= '0';
    
    wait for BIT_PERIOD * 10; -- wait for the full uart frame
    
    assert (data_out = DATA)
        report "did not receive the same data sent"
        severity failure;
 
    report "simulation complete";
    wait;
    
end process;

end test;
