----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.03.2026 01:39:54
-- Design Name: 
-- Module Name: elevator_controller - Behavioral
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

entity elevator_controller is
  Port ( 
    clk : in std_logic;
    sw : in std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0)
    );
end elevator_controller;

architecture Behavioral of elevator_controller is
type elevator_state is (IDLE, MOVING_UP, MOVING_DOWN, DOOR_OPEN_UP, DOOR_OPEN_DOWN);
signal current_state : elevator_state := IDLE;
signal next_state: elevator_state := IDLE;

signal elevator_ptr : natural range 0 to 15 := 0;

signal tick : std_logic := '0';
signal clk_counter : natural := 0;
constant c_CLK_DIVIDER : natural := 25000000; --2Hz

begin

fsm : process (current_state, sw, elevator_ptr) is
    procedure check_requests(
        signal sw_in : in std_logic_vector(15 downto 0);
        signal ptr_in : in integer range 0 to 15;
        variable req_above : out std_logic;
        variable req_below : out std_logic
    ) is
    begin
        req_above := '0';
        req_below := '0';
        for i in 0 to 15 loop
            if sw_in(i) = '1' then
                if i > ptr_in then 
                    req_above := '1';
                elsif i < ptr_in then 
                    req_below := '1';
                end if;
            end if;
        end loop;
    end procedure;

    variable v_above : std_logic;
    variable v_below : std_logic;

begin
    next_state <= current_state;
    check_requests(sw, elevator_ptr, v_above, v_below);

    case current_state is
        when IDLE =>
            if sw(elevator_ptr) = '1' then
                next_state <= DOOR_OPEN_UP;
            elsif v_above = '1' then
                next_state <= MOVING_UP;
            elsif v_below = '1' then
                next_state <= MOVING_DOWN;
            end if;

        when MOVING_UP =>
            if sw(elevator_ptr) = '1' then
                next_state <= DOOR_OPEN_UP;
            elsif v_above = '1' then
                next_state <= MOVING_UP;
            elsif v_below = '1' then
                next_state <= MOVING_DOWN;
            else
                next_state <= IDLE;
            end if;

        when MOVING_DOWN =>
            if sw(elevator_ptr) = '1' then
                next_state <= DOOR_OPEN_DOWN;
            elsif v_below = '1' then
                next_state <= MOVING_DOWN;
            elsif v_above = '1' then
                next_state <= MOVING_UP;
            else
                next_state <= IDLE;
            end if;

        when DOOR_OPEN_UP =>
            if sw(elevator_ptr) = '1' then
                next_state <= DOOR_OPEN_UP;
            else
                if v_above = '1' then
                    next_state <= MOVING_UP;
                elsif v_below = '1' then
                    next_state <= MOVING_DOWN;
                else
                    next_state <= IDLE;
                end if;
            end if;

        when DOOR_OPEN_DOWN =>
            if sw(elevator_ptr) = '1' then
                next_state <= DOOR_OPEN_DOWN;
            else
                if v_below = '1' then
                    next_state <= MOVING_DOWN;
                elsif v_above = '1' then
                    next_state <= MOVING_UP;
                else
                    next_state <= IDLE;
                end if;
            end if;

        when others =>
            next_state <= IDLE;
    end case;
end process;

p_clock_divider : process (clk) is
begin
    if rising_edge(clk) then
        tick <= '0';
        if clk_counter < c_CLK_DIVIDER then
            clk_counter <= clk_counter + 1;
        else 
            clk_counter <= 0;
            tick <= '1';
        end if;
    end if;
end process p_clock_divider;

elevator_update : process(clk) is
begin
    if rising_edge(clk) then 
        if tick = '1' then
            current_state <= next_state;
            
            case next_state  is
                when MOVING_UP =>
                    if elevator_ptr < 15 then
                        elevator_ptr <= elevator_ptr + 1;
                    end if;
                    
                when MOVING_DOWN =>
                    if elevator_ptr > 0 then
                        elevator_ptr <= elevator_ptr - 1;
                    end if;
                    
                when others =>
                    elevator_ptr <= elevator_ptr; 
            end case;
        end if; 
    end if; 
end process elevator_update;

led_update : process(elevator_ptr) is
begin
led <= "0000000000000000";
led(elevator_ptr) <= '1';
end process led_update;


end Behavioral;
