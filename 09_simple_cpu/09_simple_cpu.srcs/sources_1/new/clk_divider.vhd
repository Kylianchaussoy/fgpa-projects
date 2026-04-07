library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_divider is
    Generic (
        CLK_DIV : natural := 50_000_000 -- 1Hz
    );
    Port (
        clk_in : in std_logic;
        rst : in std_logic;
        clk_out : out std_logic
    );
end clk_divider;

architecture Behavioral of clk_divider is
    signal counter  : integer range 0 to CLK_DIV - 1 := 0;
    signal slow_clk : std_logic := '0';

begin

    process(clk_in, rst)
    begin
        if rst = '1' then
            counter  <= 0;
            slow_clk <= '0';
        elsif rising_edge(clk_in) then
            if counter = CLK_DIV - 1 then
                counter <= 0;
                slow_clk <= not slow_clk;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
 
    clk_out <= slow_clk;

end Behavioral;
