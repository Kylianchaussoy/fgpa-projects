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
    constant c_2pow16 : natural :=  65536;
    signal no_debounce_cpt : natural range 0 to c_2pow16 -1 := 0;
    signal debounce_cpt : natural range 0 to c_2pow16 -1 := 0;
    signal signal1 : std_logic := '0';
    signal signal2 : std_logic := '0';
    signal debounced_btn : std_logic;

begin
    debounce : process (clk) is
    begin
    if rising_edge(clk) then
        signal1 <= btn;
        signal2 <= not signal1;
        debounced_btn <= signal1 and signal2;
    end if;
    end process debounce;
    
    no_debounce : process (btn) is
    begin
    if btn = '1' then
        if no_debounce_cpt < c_2pow16 - 1 then
            no_debounce_cpt <= no_debounce_cpt +1;
        else no_debounce_cpt <= 0;
        end if;
    end if;
    end process no_debounce;
    
    increment_debounce : process (debounced_btn) is
    begin
    if rising_edge(debounced_btn) then
        if debounce_cpt < c_2pow16 - 1 then
            debounce_cpt <= debounce_cpt +1;
        else debounce_cpt <= 0;
        end if;
    end if;
    end process increment_debounce;
    
    switch : process (clk) is
    begin
    if rising_edge(clk)then
        if switch_debounce = '1' then
            led <= std_logic_vector(to_unsigned(debounce_cpt, 16));
        else
            led <= std_logic_vector(to_unsigned(no_debounce_cpt, 16));
        end if;
    end if;
    end process switch;

end Behavioral;
