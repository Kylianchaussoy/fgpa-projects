----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2026 14:41:36
-- Design Name: 
-- Module Name: counter_tb - Behavioral
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

entity counter_tb is
--  Port ( );
end counter_tb;

architecture test of counter_tb is
signal clk : std_logic := '0';
signal switch1 : std_logic := '0';
signal switch2 : std_logic := '0';
signal led : std_logic_vector(15 downto 0) := (others => '0');

begin
clk <= not clk after 5 ns;

counter_inst : entity work.counter_led(Behavioral)
    -- The generic map below is for fast behavioral simulation only.
    generic map (
        CLK_DIVISOR1 => 10,
        CLK_DIVISOR2 => 4
    )
    port map(
      clk => clk,
      switch2 => switch2,
      switch1 => switch1,
      led => led
    );

stimulus: process
begin
    switch1 <= '0';
    switch2 <= '0';
    wait for 20 ns;
    
    report "start counting with speed1";
    switch1 <= '1';
    wait for 500 ns; 
     
    report "start counting with speed2";
    switch2 <= '1';
    wait for 500 ns;
     
    report "reset counter";
    switch1 <= '0';
    wait for 100 ns;
     
    report "simulation finished";
    wait;
end process stimulus;

end test;
