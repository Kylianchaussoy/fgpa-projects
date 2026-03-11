----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2026 19:42:04
-- Design Name: 
-- Module Name: debounce - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce is
  Port (
    clk : in std_logic;
    btn : in std_logic;
    switch_debounce : in std_logic;
    led : out std_logic_vector(15 downto 0));
end debounce;

architecture Behavioral of debounce is
    constant c_2POW16 : natural :=  65536;
    signal s_no_debounce_cpt : natural range 0 to c_2POW16 -1 := 0;
    signal s_debounce_cpt : natural range 0 to c_2POW16 -1 := 0;
    signal s_wire1 : std_logic := '0';
    signal s_wire2 : std_logic := '0';
    signal s_debounced_btn : std_logic;

begin
    p_debounce : process (clk) is
    begin
    if rising_edge(clk) then
        s_wire1 <= btn;
        s_wire2 <= not s_wire1;
        s_debounced_btn <= s_wire1 and s_wire2;
    end if;
    end process p_debounce;
    
    p_no_debounce_counter : process (btn) is
    begin
    if btn = '1' then
        if s_no_debounce_cpt < c_2POW16 - 1 then
            s_no_debounce_cpt <= s_no_debounce_cpt +1;
        else s_no_debounce_cpt <= 0;
        end if;
    end if;
    end process p_no_debounce_counter;
    
    p_debounce_counter : process (s_debounced_btn) is
    begin
    if rising_edge(s_debounced_btn) then
        if s_debounce_cpt < c_2POW16 - 1 then
            s_debounce_cpt <= s_debounce_cpt +1;
        else s_debounce_cpt <= 0;
        end if;
    end if;
    end process p_debounce_counter;
    
    p_switch : process (clk) is
    begin
    if rising_edge(clk)then
        if switch_debounce = '1' then
            led <= std_logic_vector(to_unsigned(s_debounce_cpt, 16));
        else
            led <= std_logic_vector(to_unsigned(s_no_debounce_cpt, 16));
        end if;
    end if;
    end process p_switch;

end Behavioral;
