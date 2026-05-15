library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_point_mul is
    Port (
        a : in signed(27 downto 0);
        b : in signed(27 downto 0);
        result : out signed(27 downto 0)
    );
end fixed_point_mul;

architecture Behavioral of fixed_point_mul is
    signal product : signed(55 downto 0);

begin

    product <= a * b;

    process(product)
    begin

        -- no overflow when multiplying the two Q4.24 numbers
        if product(55 downto 51) = "00000" or product(55 downto 51) = "11111" then
            result <= product(51 downto 24);
        
        -- positive overflow, we put the maximum value
        elsif product(55) = '0' then
            result <= "0111111111111111111111111111";

        -- negative overflow: we put the minimum value
        else
            result <= "1000000000000000000000000000";
        end if;
        
    end process;

end Behavioral;
