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
generic (
    GREEN_DELAY      : natural := 4;
    YELLOW_DELAY     : natural := 2;
    DOUBLE_RED_DELAY : natural := 1;
    CLK_DIVIDER : natural := 100_000_000 --1Hz
);

  Port (
    clk : in std_logic;
    rst : in std_logic;
    led1 : out std_logic_vector(2 downto 0);
    led2 : out std_logic_vector(2 downto 0));
end traffic_light_controller;

architecture Behavioral of traffic_light_controller is
signal s_tick : std_logic := '0';
signal s_delay : natural := 0;
signal s_clk_counter : natural := 0;

type t_lights_state is (GREEN_RED, RED_GREEN, YELLOW_RED, RED_YELLOW, RED_RED_1, RED_RED_2);
signal s_current_state, s_next_state: t_lights_state;

subtype t_light_color is std_logic_vector(2 downto 0);
subtype t_delay_time is natural;
constant c_RED : t_light_color := "001";
constant c_YELLOW : t_light_color := "011";
constant c_GREEN : t_light_color := "111";

begin

p_clock_divider : process (clk) is
begin
if rising_edge(clk) then
    s_tick <= '0';
    if s_clk_counter >= CLK_DIVIDER - 1 then
       s_tick <= '1';
       s_clk_counter <= 0;
    else 
       s_clk_counter <= s_clk_counter + 1;
    end if;
end if;
end process p_clock_divider;

process(clk) 
begin
if rising_edge(clk) then
    if rst ='1' then
        s_current_state <= GREEN_RED;
        s_delay <= 0;
    elsif s_tick = '1' then
        s_current_state <= s_next_state;
        if s_next_state /= s_current_state then
            s_delay <= 0;
        elsif s_delay < GREEN_DELAY - 1 then -- green delay is the max
            s_delay <= s_delay + 1;
        end if;
    end if;
end if;
end process;

p_fsm : process (s_current_state, s_delay) is
begin
led1 <= c_RED;
led2 <= c_RED;
case s_current_state is
    when GREEN_RED =>
        led1 <= c_GREEN;
        led2 <= c_RED;
        if s_delay >= GREEN_DELAY - 1 then
            s_next_state <= YELLOW_RED;
        else
            s_next_state <= GREEN_RED;
        end if;
    when YELLOW_RED =>
        led1 <= c_YELLOW;
        led2 <= c_RED;
        if s_delay >= YELLOW_DELAY - 1 then
            s_next_state <= RED_RED_1;
        else
            s_next_state <= YELLOW_RED;
        end if;
    when RED_RED_1 =>
        led1 <= c_RED;
        led2 <= c_RED;
        if s_delay >= DOUBLE_RED_DELAY - 1 then
            s_next_state <= RED_GREEN;
        else
            s_next_state <= RED_RED_1;
        end if;
    when RED_GREEN =>
        led1 <= c_RED;
        led2 <= c_GREEN;
        if s_delay >= GREEN_DELAY - 1 then
            s_next_state <= RED_YELLOW;
        else
            s_next_state <= RED_GREEN;
        end if;
    when RED_YELLOW =>
        led1 <= c_RED;
        led2 <= c_YELLOW;
        if s_delay >= YELLOW_DELAY - 1 then
            s_next_state <= RED_RED_2;
        else
            s_next_state <= RED_YELLOW;
        end if;
    when RED_RED_2 =>
        led1 <= c_RED;
        led2 <= c_RED;
        if s_delay >= DOUBLE_RED_DELAY - 1 then
            s_next_state <= GREEN_RED;
        else
            s_next_state <= RED_RED_2;
        end if;
    when others =>
        s_next_state <= s_current_state;
end case;
end process p_fsm;

end Behavioral;
