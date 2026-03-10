----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2026 16:12:54
-- Design Name: 
-- Module Name: traffic_light_controller - Behavioral
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

entity traffic_light_controller is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    led1 : out std_logic_vector(2 downto 0);
    led2 : out std_logic_vector(2 downto 0));
end traffic_light_controller;

architecture Behavioral of traffic_light_controller is
signal slow_clk : std_logic := '0';
signal delay : natural := 0;
signal clk_counter : natural := 0;

type lights_state is (GREEN_RED, RED_GREEN, YELLOW_RED, RED_YELLOW, RED_RED_1, RED_RED_2);
signal current_state, next_state: lights_state;
constant c_CLK_DIVIDER : natural := 50000000; --1Hz

subtype light_color is std_logic_vector(2 downto 0);
subtype delay_time is natural;
constant c_RED : light_color := "001";
constant c_YELLOW : light_color := "011";
constant c_GREEN : light_color := "111";
constant c_GREEN_DELAY  : delay_time := 5;
constant c_YELLOW_DELAY : delay_time := 2;
constant c_DOUBLE_RED_DELAY : delay_time := 1;

begin

p_clock_divider : process (clk) is
begin
if rising_edge(clk) then
    if clk_counter < c_CLK_DIVIDER then
        clk_counter <= clk_counter + 1;
    else 
        clk_counter <= 0;
        slow_clk <= not slow_clk;
    end if;
end if;
end process p_clock_divider;

process(slow_clk, rst) 
begin
if rst ='1' then
    current_state <= GREEN_RED;
    delay <= 0;
elsif(rising_edge(slow_clk)) then 
    current_state <= next_state;
    if current_state /= next_state then
        delay <= 0;
    elsif delay < c_GREEN_DELAY then
        delay <= delay + 1;
    end if;
end if; 
end process;

fsm : process (current_state, delay, rst) is
begin
if rst = '1' then
   next_state <= GREEN_RED;
else
    case current_state is
    when GREEN_RED =>
        led1 <= c_GREEN;
        led2 <= c_RED;
        if delay >= c_GREEN_DELAY then
            next_state <= YELLOW_RED;
        else
            next_state <= GREEN_RED;
        end if;
    when YELLOW_RED =>
        led1 <= c_YELLOW;
        led2 <= c_RED;
        if delay >= c_YELLOW_DELAY then
            next_state <= RED_RED_1;
        else
            next_state <= YELLOW_RED;
        end if;
    when RED_RED_1 =>
        led1 <= c_RED;
        led2 <= c_RED;
        if delay >= c_DOUBLE_RED_DELAY then
            next_state <= RED_GREEN;
        else
            next_state <= RED_RED_1;
        end if;
    when RED_GREEN =>
        led1 <= c_RED;
        led2 <= c_GREEN;
        if delay >= c_GREEN_DELAY then
            next_state <= RED_YELLOW;
        else
            next_state <= RED_GREEN;
        end if;
    when RED_YELLOW =>
        led1 <= c_RED;
        led2 <= c_YELLOW;
        if delay >= c_YELLOW_DELAY then
            next_state <= RED_RED_2;
        else
            next_state <= RED_YELLOW;
        end if;
    when RED_RED_2 =>
        led1 <= c_RED;
        led2 <= c_RED;
        if delay >= c_DOUBLE_RED_DELAY then
            next_state <= GREEN_RED;
        else
            next_state <= RED_RED_2;
        end if;
    when others =>
        next_state <= current_state;
    end case;
end if;
end process fsm;

end Behavioral;
