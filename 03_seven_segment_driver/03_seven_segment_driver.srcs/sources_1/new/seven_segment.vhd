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
  Port ( 
    clk : in std_logic;
    dp : out std_logic;
    an : out std_logic_vector(3 downto 0);
    seg : out std_logic_vector(6 downto 0));
end seven_segment;

architecture Behavioral of seven_segment is
signal slow_clk1 : std_logic := '0';
signal slow_clk2 : std_logic := '0';
signal an_sig : std_logic_vector(3 downto 0) := "1110";
signal clock_counter1 : natural := 0;
signal clock_counter2 : natural := 0;
signal msg_ptr : integer range 0 to 6 := 6;
signal char0, char1, char2, char3 : std_logic_vector(6 downto 0);

constant clock_divider1 : natural := 100000; --500Hz
constant clock_divider2 : natural := 25000000; --2Hz
constant B : std_logic_vector(6 downto 0) := "0000000";
constant A : std_logic_vector(6 downto 0) := "0001000";
constant S : std_logic_vector(6 downto 0) := "0010010";
constant Y : std_logic_vector(6 downto 0) := "0010001";
constant three : std_logic_vector(6 downto 0) := "0110000";

type array_message is array (6 downto 0) of std_logic_vector(6 downto 0);
constant message : array_message := (B, A, S, Y, S, three, "1111111");

begin
    dp <= '1';
    
    p_clock_divider : process (clk) is
    begin
    if rising_edge(clk) then
        if clock_counter1 < clock_divider1 then
            clock_counter1 <= clock_counter1 + 1;
        else 
            clock_counter1 <= 0;
            slow_clk1 <= not slow_clk1;
        end if;
        
        if clock_counter2 < clock_divider2 then
            clock_counter2 <= clock_counter2 + 1;
        else 
            clock_counter2 <= 0;
            slow_clk2 <= not slow_clk2;
        end if;
    end if;
    end process p_clock_divider;
        
    p_4_displays : process (slow_clk1) is
    begin
    if rising_edge(slow_clk1) then
        an_sig <= an_sig(2 downto 0) & an_sig(3);
    end if;
    end process p_4_displays;
    
    p_scroll : process(slow_clk2)
    begin
        if rising_edge(slow_clk2) then
            if msg_ptr = 0 then
                msg_ptr <= 6;
            else
                msg_ptr <= msg_ptr - 1;
            end if;
        end if;
    end process p_scroll;
    
    an <= an_sig;
    
    char3 <= MESSAGE(msg_ptr);
    char2 <= MESSAGE((msg_ptr - 1) mod 7);
    char1 <= MESSAGE((msg_ptr - 2) mod 7);
    char0 <= MESSAGE((msg_ptr - 3) mod 7); 
    
    with an_sig select
        seg <= char3 when "0111",
               char2 when "1011",
               char1 when "1101",
               char0 when "1110",
               "1111111" when others;

end Behavioral;
