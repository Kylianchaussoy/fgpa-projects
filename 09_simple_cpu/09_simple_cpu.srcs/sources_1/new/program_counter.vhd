----------------------------------------------------------------------------------
--  Program Counter
--  8-bit PC with increment, jump, and reset
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
 Port ( 
    clk : in std_logic;
    rst : in std_logic;

    inc : in std_logic;
    load : in std_logic;
    halt : in std_logic;
    jump_addr : in std_logic_vector(7 downto 0);
    pc_out : out std_logic_vector(7 downto 0)
 );
end program_counter;

architecture Behavioral of program_counter is
signal pc_reg : unsigned(7 downto 0) := (others => '0');

begin

    pc_out <= std_logic_vector(pc_reg);

    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if halt = '1' then
                null;
            elsif load = '1' then
                pc_reg <= unsigned(jump_addr);
            elsif inc = '1' then
                pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;

end Behavioral;
