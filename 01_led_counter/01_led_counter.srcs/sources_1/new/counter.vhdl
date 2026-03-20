----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2026 17:19:38
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity counter_led is
generic (
    CLK_DIVISOR1 : natural := 1_000_000;
    CLK_DIVISOR2 : natural := 100_000
);
Port ( 
  clk : in std_logic;
  switch2 : in std_logic;
  switch1 : in std_logic;
  led : out std_logic_vector(15 downto 0)
);
end counter_led;

architecture Behavioral of counter_led is
    constant c_2POW16 : natural :=  65536;
    signal s_cpt : natural range 0 to c_2POW16 -1 := 0;
    signal s_clk_count : natural := 0;
    signal s_tick : std_logic := '0'; 

begin
    p_clk_divider : process (clk) is
    variable v_divisor : natural;
    begin
    if rising_edge(clk) then
        s_tick <= '0';
        
        if switch2 = '1' then
            v_divisor := CLK_DIVISOR2;
        else v_divisor := CLK_DIVISOR1;
        end if;

        if s_clk_count >= v_divisor - 1 then
            s_tick <= '1';
            s_clk_count <= 0;
        else
            s_clk_count <= s_clk_count + 1;
        end if;
    end if;
    end process p_clk_divider;

    p_increment : process (clk) is
    begin
    if rising_edge(clk) then
        if s_tick = '1' then
            if switch1 = '1' then
                s_cpt <= (s_cpt + 1) mod 65536;
            else s_cpt <= 0;
            end if;
        end if;
    end if;
    end process p_increment;
            
    led <= std_logic_vector(to_unsigned(s_cpt, 16));

end Behavioral;
