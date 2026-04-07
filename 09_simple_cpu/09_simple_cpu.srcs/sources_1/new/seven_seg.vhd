----------------------------------------------------------------------------------
-- Displays a 16-bit hex value across the 4 digits
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg is
    port (
        clk : in std_logic;
        data_in : in std_logic_vector(15 downto 0);
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0)
    );
end entity;

architecture Behavioral of seven_seg is
    signal scan_counter : unsigned(19 downto 0) := (others => '0');
    signal digit_select : std_logic_vector(1 downto 0);
    signal hex_digit : std_logic_vector(3 downto 0);

begin

    process(clk) 
    begin
        if rising_edge(clk) then 
            scan_counter <= scan_counter + 1;
        end if;
    end process;

    digit_select <= std_logic_vector(scan_counter(19 downto 18));

    process(digit_select, data_in)
    begin
        case digit_select is
            when "00" => an <= "1110"; hex_digit <= data_in(3 downto 0);
            when "01" => an <= "1101"; hex_digit <= data_in(7 downto 4);
            when "10" => an <= "1011"; hex_digit <= data_in(11 downto 8);
            when "11" => an <= "0111"; hex_digit <= data_in(15 downto 12);
            when others => an <= "1111";
        end case;
    end process;

    -- Hex to 7-segment decoder
    with hex_digit select
        seg <= "1000000" when x"0", "1111001" when x"1", "0100100" when x"2",
               "0110000" when x"3", "0011001" when x"4", "0010010" when x"5",
               "0000010" when x"6", "1111000" when x"7", "0000000" when x"8",
               "0010000" when x"9", "0001000" when x"A", "0000011" when x"B",
               "1000110" when x"C", "0100001" when x"D", "0000110" when x"E",
               "0001110" when x"F", "1111111" when others;
end architecture;
