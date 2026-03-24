----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2026 16:00:02
-- Design Name: 
-- Module Name: elevator_controller_tb - Behavioral
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

entity elevator_controller_tb is
--  Port ( );
end elevator_controller_tb;

architecture test of elevator_controller_tb is
signal clk : std_logic;
signal switch : std_logic_vector(15 downto 0);
signal led : std_logic_vector(15 downto 0);
constant CLK_PERIOD : time := 10 ns;

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

elevator_controller_inst : entity work.elevator_controller(Behavioral)
    generic map (
        CLK_DIVIDER => 10
    )
    port map(
        clk => clk,
        switch => switch,
        led => led
    );
    
process
begin
    wait for 100 ns;
    
    switch(8) <= '1'; -- call elevator at floor 8
    wait until led(8) = '1'; -- arrived at floor 8
    switch(8) <= '0'; -- can leave floor 8
    
    switch(0) <= '1';
    wait for 110 ns; -- wait 10 cycles for s_tick + 1 cycle for the fsm to register floor 0
    switch(9) <= '1';
    switch(2) <= '1';
    
    -- elevator should go down first
    wait until led(2) = '1';
    wait for 1 us;
    switch(2) <= '0';
    
    wait until led(0) = '1';
    switch(0) <= '0';
    wait until led(9) = '1';
    switch(9) <= '0';

    report "simulation complete";
    wait;
end process;

end test;
