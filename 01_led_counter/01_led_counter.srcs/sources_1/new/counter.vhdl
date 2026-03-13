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

entity counter is
generic (
    CLK_DIVISOR1 : natural := 1_000_000;
    CLK_DIVISOR2 : natural := 100_000
);
    Port ( clk : in std_logic;
           switch2 : in std_logic;
           switch1 : in std_logic;
           led : out std_logic_vector(15 downto 0)
           );
end counter;

architecture Behavioral of counter is
    constant c_2POW16 : natural :=  65536;
    signal s_cpt : natural range 0 to c_2POW16 -1 := 0;
    signal s_clk_divided : std_logic := '0';
    signal s_clk_count : natural := 0;

begin
    p_clk_divider : process (clk) is
    variable v_divisor : natural;
    begin
    if rising_edge(clk) then
        if switch2 = '1' then
            v_divisor := CLK_DIVISOR2;
        else v_divisor := CLK_DIVISOR1;
        end if;

        s_clk_count <= s_clk_count +1;
        if s_clk_count >= v_divisor then
            s_clk_divided <= not s_clk_divided;
            s_clk_count <= 0;
        end if;
    end if;
    end process p_clk_divider;

    p_increment : process (s_clk_divided) is
    begin
    if rising_edge(s_clk_divided) then
        if switch1 = '1' then
            if s_cpt < c_2pow16 - 1 then
                s_cpt <= s_cpt + 1;
            else s_cpt <= 0;
            end if;
        else s_cpt <= 0;
        end if;
    end if;
    end process p_increment;
            
    p_led_update : process (s_cpt) is
    begin
        led <= std_logic_vector(to_unsigned(s_cpt, 16));
    end process p_led_update;
        

end Behavioral;
