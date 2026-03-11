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
    switch : in std_logic_vector(15 downto 0);
    led : out std_logic_vector(15 downto 0)
    );
end elevator_controller;

architecture Behavioral of elevator_controller is
type t_elevator_state is (IDLE, MOVING_UP, MOVING_DOWN, DOOR_OPEN_UP, DOOR_OPEN_DOWN);
constant c_MAX_FLOOR : natural := 15;
signal s_current_state : t_elevator_state := IDLE;
signal s_next_state: t_elevator_state := IDLE;
signal s_elevator_ptr : natural range 0 to c_MAX_FLOOR := 0;
signal s_tick : std_logic := '0';
signal s_clk_counter : natural := 0;
constant c_CLK_DIVIDER : natural := 25000000; --2Hz

begin

p_fsm : process (s_current_state, switch, s_elevator_ptr) is
    procedure check_requests(
        signal sw_in : in std_logic_vector(c_MAX_FLOOR downto 0);
        signal ptr_in : in integer range 0 to c_MAX_FLOOR;
        variable req_above : out std_logic;
        variable req_below : out std_logic
    ) is
    begin
        req_above := '0';
        req_below := '0';
        for i in 0 to c_MAX_FLOOR loop
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
    s_next_state <= s_current_state;
    check_requests(switch, s_elevator_ptr, v_above, v_below);

    case s_current_state is
        when IDLE =>
            if switch(s_elevator_ptr) = '1' then
                s_next_state <= DOOR_OPEN_UP;
            elsif v_above = '1' then
                s_next_state <= MOVING_UP;
            elsif v_below = '1' then
                s_next_state <= MOVING_DOWN;
            end if;

        when MOVING_UP =>
            if switch(s_elevator_ptr) = '1' then
                s_next_state <= DOOR_OPEN_UP;
            elsif v_above = '1' then
                s_next_state <= MOVING_UP;
            elsif v_below = '1' then
                s_next_state <= MOVING_DOWN;
            else
                s_next_state <= IDLE;
            end if;

        when MOVING_DOWN =>
            if switch(s_elevator_ptr) = '1' then
                s_next_state <= DOOR_OPEN_DOWN;
            elsif v_below = '1' then
                s_next_state <= MOVING_DOWN;
            elsif v_above = '1' then
                s_next_state <= MOVING_UP;
            else
                s_next_state <= IDLE;
            end if;

        when DOOR_OPEN_UP =>
            if switch(s_elevator_ptr) = '1' then
                s_next_state <= DOOR_OPEN_UP;
            else
                if v_above = '1' then
                    s_next_state <= MOVING_UP;
                elsif v_below = '1' then
                    s_next_state <= MOVING_DOWN;
                else
                    s_next_state <= IDLE;
                end if;
            end if;

        when DOOR_OPEN_DOWN =>
            if switch(s_elevator_ptr) = '1' then
                s_next_state <= DOOR_OPEN_DOWN;
            else
                if v_below = '1' then
                    s_next_state <= MOVING_DOWN;
                elsif v_above = '1' then
                    s_next_state <= MOVING_UP;
                else
                    s_next_state <= IDLE;
                end if;
            end if;

        when others =>
            s_next_state <= IDLE;
    end case;
end process p_fsm;

p_clock_divider : process (clk) is
begin
    if rising_edge(clk) then
        s_tick <= '0';
        if s_clk_counter < c_CLK_DIVIDER then
            s_clk_counter <= s_clk_counter + 1;
        else 
            s_clk_counter <= 0;
            s_tick <= '1';
        end if;
    end if;
end process p_clock_divider;

elevator_update : process(clk) is
begin
    if rising_edge(clk) then 
        if s_tick = '1' then
            s_current_state <= s_next_state;
            
            case s_next_state  is
                when MOVING_UP =>
                    if s_elevator_ptr < c_MAX_FLOOR then
                        s_elevator_ptr <= s_elevator_ptr + 1;
                    end if;
                    
                when MOVING_DOWN =>
                    if s_elevator_ptr > 0 then
                        s_elevator_ptr <= s_elevator_ptr - 1;
                    end if;
                    
                when others =>
                    s_elevator_ptr <= s_elevator_ptr; 
            end case;
        end if; 
    end if; 
end process elevator_update;


p_led_update : process(s_elevator_ptr) is
begin
led <= "0000000000000000";
led(s_elevator_ptr) <= '1';
end process p_led_update;


end Behavioral;
