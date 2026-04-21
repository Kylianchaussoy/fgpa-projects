library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk : in  std_logic;
        mem_read : in  std_logic;
        mem_write : in  std_logic;
        funct3 : in  std_logic_vector(2 downto 0);
        addr : in  std_logic_vector(31 downto 0);
        wr_data : in  std_logic_vector(31 downto 0);
        rd_data : out std_logic_vector(31 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is

    type ram_t is array (0 to 63) of std_logic_vector(7 downto 0);
    signal RAM : ram_t := (others => (others => '0'));

    signal word_addr : integer;

begin

    -- Convert byte address to word index
    word_addr <= to_integer(unsigned(addr(7 downto 2)));

    process(clk)
        variable byte0 : std_logic_vector(7 downto 0);
        variable byte1 : std_logic_vector(7 downto 0);
        variable byte2 : std_logic_vector(7 downto 0);
        variable byte3 : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk) then
            if mem_write = '1' then

                case funct3 is
                    -- SB : write 1 byte
                    when "000" =>
                        RAM(word_addr) <= wr_data(7 downto 0);

                    -- SH : write 2 bytes
                    when "001" =>
                        RAM(word_addr) <= wr_data(7  downto 0);
                        RAM(word_addr + 1) <= wr_data(15 downto 8);

                    -- SW : write 4 bytes
                    when "010" =>
                        RAM(word_addr) <= wr_data(7  downto 0);
                        RAM(word_addr + 1) <= wr_data(15 downto 8);
                        RAM(word_addr + 2) <= wr_data(23 downto 16);
                        RAM(word_addr + 3) <= wr_data(31 downto 24);

                    when others => null;
                end case;

            end if;

            if mem_read = '1' then

                byte0 := RAM(word_addr);
                byte1 := RAM(word_addr + 1);
                byte2 := RAM(word_addr + 2);
                byte3 := RAM(word_addr + 3);

                case funct3 is

                    -- LB : sign extend the byte
                    when "000" =>
                        rd_data <= (31 downto 8 => byte0(7)) & byte0;

                    -- LH : sign extend the half-word
                    when "001" =>
                        rd_data <= (31 downto 16 => byte1(7)) & byte1 & byte0;

                    -- LW : full 32-bit word
                    when "010" =>
                        rd_data <= byte3 & byte2 & byte1 & byte0;

                    -- LBU
                    when "100" =>
                        rd_data <= (31 downto 8 => '0') & byte0;

                    -- LHU
                    when "101" =>
                        rd_data <= (31 downto 16 => '0') & byte1 & byte0;

                    when others =>
                        rd_data <= (others => '0');

                end case;
            end if;
        end if;
    end process;

end Behavioral;
