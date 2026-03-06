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
    Port ( clk : in std_logic;
           switch2 : in std_logic;
           switch1 : in std_logic;
           led : out std_logic_vector(15 downto 0));
end counter;

architecture Behavioral of counter is
    constant c_2pow16 : natural :=  65536;
    signal cpt : natural range 0 to c_2pow16 -1 := 0;
    constant clk_divisor1 : natural := 1000000;
    constant clk_divisor2 : natural := 100000;
    signal clk_divided : std_logic := '0';
    signal clk_count : natural := 0;

begin
    clk_divider : process (clk) is
    variable divisor : natural;
    begin
    if rising_edge(clk) then
        if switch2 = '1' then
            divisor := clk_divisor2;
        else divisor := clk_divisor1;
        end if;

        clk_count <= clk_count +1;
        if clk_count >= divisor then
            clk_divided <= not clk_divided;
            clk_count <= 0;
        end if;
    end if;
    end process clk_divider;

    increment : process (clk_divided) is
    begin
    if rising_edge(clk_divided) then
        if switch1 = '1' then
            if cpt < c_2pow16 - 1 then
                cpt <= cpt + 1;
            else cpt <= 0;
            end if;
        else cpt <= 0;
        end if;
    end if;
    end process increment;
            
    led_update : process (cpt) is
    begin
        led <= std_logic_vector(to_unsigned(cpt, 16));
    end process led_update;
        

end Behavioral;
