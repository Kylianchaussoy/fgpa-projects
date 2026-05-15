library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity frame_buffer is
    Port (
        clk_write : in std_logic;
        we : in std_logic;
        addr_write : in unsigned(18 downto 0);
        data_in : in unsigned(3 downto 0);

        clk_read : in std_logic;
        addr_read : in unsigned(18 downto 0);
        data_out : out unsigned(3 downto 0)
    );
end frame_buffer;

architecture Behavioral of frame_buffer is
    -- basys3 BRAM is 1800kb, we use 1228,8kb here
    type ram_type is array (0 to 307199) of unsigned(3 downto 0);
    signal ram : ram_type := (others => (others => '0'));

begin

    process(clk_write)
    begin
        if rising_edge(clk_write) then
            if we = '1' then
                ram(to_integer(addr_write)) <= data_in;
            end if;
        end if;
    end process;

    process(clk_read)
    begin
        if rising_edge(clk_read) then
            data_out <= ram(to_integer(addr_read));
        end if;
    end process;

end Behavioral;
