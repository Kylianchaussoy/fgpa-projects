----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.03.2026 15:53:34
-- Design Name: 
-- Module Name: seven_segment - Behavioral
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

entity seven_segment is
Generic (
    CLOCK_DIVIDER1 : natural := 100_000; --1000Hz
    CLOCK_DIVIDER2 : natural := 50_000_000 --2Hz
);

Port ( 
    clk : in std_logic;
    dp : out std_logic;
    an : out std_logic_vector(3 downto 0);
    seg : out std_logic_vector(6 downto 0));
end seven_segment;

architecture Behavioral of seven_segment is
signal s_an : std_logic_vector(3 downto 0) := "1110";
signal s_clock_counter1 : natural := 0;
signal s_clock_counter2 : natural := 0;
signal s_tick1 : std_logic := '0';
signal s_tick2 : std_logic := '0';
signal s_msg_ptr : integer range 0 to 6 := 6;
signal s_char0, s_char1, s_char2, s_char3 : std_logic_vector(6 downto 0);

constant c_B : std_logic_vector(6 downto 0) := "0000000";
constant c_A : std_logic_vector(6 downto 0) := "0001000";
constant c_S : std_logic_vector(6 downto 0) := "0010010";
constant c_Y : std_logic_vector(6 downto 0) := "0010001";
constant c_3 : std_logic_vector(6 downto 0) := "0110000";

type t_array_message is array (6 downto 0) of std_logic_vector(6 downto 0);
constant c_MESSAGE : t_array_message := (c_B, c_A, c_S, c_Y, c_S, c_3, "1111111");

begin
    dp <= '1';
    
    p_clock_divider : process (clk) is
    begin
    if rising_edge(clk) then
        s_tick1 <= '0';
        if s_clock_counter1 >= CLOCK_DIVIDER1 then
            s_tick1 <= '1';
            s_clock_counter1 <= 0;
        else 
            s_clock_counter1 <= s_clock_counter1 + 1;
        end if;
        
        s_tick2 <= '0';
        if s_clock_counter2 >= CLOCK_DIVIDER2 then
            s_tick2 <= '1';
            s_clock_counter2 <= 0;
        else 
            s_clock_counter2 <= s_clock_counter2 + 1;
        end if;
    end if;
    end process p_clock_divider;
    
    process (clk)
    begin
    if rising_edge(clk) then
        -- display all 4 digit
        if s_tick1 = '1' then
            s_an <= s_an(2 downto 0) & s_an(3);
        end if;
        
        -- scroll message
        if s_tick2 = '1' then
            if s_msg_ptr = 0 then
                s_msg_ptr <= 6;
            else
                s_msg_ptr <= s_msg_ptr - 1;
            end if;
        end if;
    end if;
    end process p_4_displays;
    
    an <= s_an;
    
    s_char3 <= c_MESSAGE(s_msg_ptr);
    s_char2 <= c_MESSAGE((s_msg_ptr - 1) mod 7);
    s_char1 <= c_MESSAGE((s_msg_ptr - 2) mod 7);
    s_char0 <= c_MESSAGE((s_msg_ptr - 3) mod 7); 
    
    with s_an select
        seg <= s_char3 when "0111",
               s_char2 when "1011",
               s_char1 when "1101",
               s_char0 when "1110",
               (others => '1') when others;

end Behavioral;
