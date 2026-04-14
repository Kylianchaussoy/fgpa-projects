library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Generic (XLEN : integer := 32);
    Port ( 
    clk : in std_logic;
    rst : in std_logic;

    wr_en : in std_logic;
    wr_addr : in std_logic_vector(4 downto 0);
    wr_data : in std_logic_vector(XLEN-1 downto 0);

    rs1_addr : in std_logic_vector(4 downto 0);
    rs1_data : out std_logic_vector(XLEN-1 downto 0);

    rs2_addr : in std_logic_vector(4 downto 0);
    rs2_data : out std_logic_vector(XLEN-1 downto 0)
    );
end register_file;

architecture Behavioral of register_file is

-- 32 x 32-bit registers
type reg_array is array(0 to 31) of std_logic_vector(XLEN-1 downto 0);
signal registers : reg_array := (others => (others => '0'));

begin
    -- add forwarding bypass
    process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if wr_en = '1' and wr_addr /= "00000" then
                registers(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process;

    rs1_data <= (others => '0') when rs1_addr = "00000"
                else registers(to_integer(unsigned(rs1_addr)));

    rs2_data <= (others => '0') when rs2_addr = "00000"
                else registers(to_integer(unsigned(rs2_addr)));

end Behavioral;
