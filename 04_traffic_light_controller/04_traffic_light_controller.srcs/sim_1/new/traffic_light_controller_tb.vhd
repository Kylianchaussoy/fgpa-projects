----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2026 15:28:52
-- Design Name: 
-- Module Name: traffic_light_controller_tb - Behavioral
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

entity traffic_light_controller_tb is
--  Port ( );
end traffic_light_controller_tb;

architecture test of traffic_light_controller_tb is
signal clk : std_logic;
signal rst : std_logic;
signal led1 : std_logic_vector(2 downto 0);
signal led2 : std_logic_vector(2 downto 0);
    
constant CLK_PERIOD : time := 10 ns;

subtype t_light_color is std_logic_vector(2 downto 0);
constant c_RED : t_light_color := "001";
constant c_YELLOW : t_light_color := "011";
constant c_GREEN : t_light_color := "111";

constant SIM_CLK_DIVIDER : natural := 100;
constant SIM_SEC : time := SIM_CLK_DIVIDER * CLK_PERIOD; -- represents one second in real life

begin

traffic_light_controller_inst : entity work.traffic_light_controller(Behavioral)
    generic map (
        CLK_DIVIDER => 100
    )
    port map(
        clk => clk,
        rst => rst,
        led1 => led1,
        led2 => led2
    );

clk_process : process
begin
    clk <= '0'; 
    wait for CLK_PERIOD/2;
    clk <= '1'; 
    wait for CLK_PERIOD/2;
end process;

process
begin
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait for 20 ns;
    
    assert(led1 = c_GREEN and led2 = c_RED) severity failure;
    wait for 4 * SIM_SEC;
    
    assert(led1 = c_YELLOW and led2 = c_RED) severity failure;
    wait for 2 * SIM_SEC;
    
    assert(led1 = c_RED and led2 = c_RED) severity failure;
    wait for 1 * SIM_SEC;
    
    assert(led1 = c_RED  and led2 = c_GREEN) severity failure;
    wait for 4 * SIM_SEC;
    
    assert(led1 = c_RED  and led2 = c_YELLOW) severity failure;
    wait for 2 * SIM_SEC;
    
    assert(led1 = c_RED  and led2 = c_RED) severity failure;
    wait for 1 * SIM_SEC;
    
    assert(led1 = c_GREEN and led2 = c_RED) severity failure;
        
    report "simulation complete";
    wait;
    
end process;


end test;
