----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2026 15:09:05
-- Design Name: 
-- Module Name: seven_segment_tb - Behavioral
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

entity seven_segment_tb is
--  Port ( );
end seven_segment_tb;

architecture test of seven_segment_tb is
signal clk : std_logic;
signal dp : std_logic;
signal an : std_logic_vector(3 downto 0);
signal seg : std_logic_vector(6 downto 0);
constant CLK_PERIOD : time := 10 ns;

begin

seven_segment_inst : entity work.seven_segment(Behavioral)
    generic map (
            CLOCK_DIVIDER1 => 10,
            CLOCK_DIVIDER2 => 50
        )
    port map(
        clk => clk,
        dp => dp,
        an => an,
        seg => seg
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
    wait for 2000 ns; 
    report "simulation complete";
    wait;
end process;

end test;
