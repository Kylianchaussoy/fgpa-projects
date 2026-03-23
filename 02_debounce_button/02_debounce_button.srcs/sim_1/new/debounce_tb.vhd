----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2026 14:07:16
-- Design Name: 
-- Module Name: debounce_tb - Behavioral
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

entity debounce_tb is
--  Port ( );
end debounce_tb;

architecture Behavioral of debounce_tb is
signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal button_in : std_logic := '0';
signal button_out : std_logic := '0';

begin
clk <= not clk after 5 ns;

debounce_button_inst : entity work.debounce_button(Behavioral)
    port map (
        clk => clk,
        rst => rst,
        button_in => button_in,
        button_out => button_out
    );

stimulus : process
begin
    rst <= '1';
    wait for 20ns;
    rst <= '0';
    wait for 20ns;
    
    report "starting noisy press";
    for i in 1 to 1_000_000 loop
        button_in <= '1'; wait for 10 ns;
        button_in <= '0'; wait for 10 ns;
    end loop;
    button_in <= '1';
    wait for 20 ms;
    
    report "starting noisy release...";
    for i in 1 to 500_000 loop
        button_in <= '0'; wait for 20 ns;
        button_in <= '1'; wait for 20 ns;
    end loop;
    button_in <= '0';
    wait for 1 ms;
    
    report "simulation finished";
    wait;

end process stimulus;

end Behavioral;
