----------------------------------------------------------------------------------
--  Register File
--  4 general-purpose 8-bit registers: R0, R1, R2, R3
--  2 read ports (Rs1, Rs2), 1 write port (Rd)
--  R0 is hardwired to 0
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
 Port ( 
    clk : in std_logic;
    rst : in std_logic;

    wr_en : in std_logic;
    wr_addr : in std_logic_vector(1 downto 0);
    wr_data : in std_logic_vector(7 downto 0);

    rs1_addr : in std_logic_vector(1 downto 0);
    rs1_data : out std_logic_vector(7 downto 0);

    rs2_addr : in std_logic_vector(1 downto 0);
    rs2_data : out std_logic_vector(7 downto 0)
 );
end register_file;

architecture Behavioral of register_file is

-- 4 x 8-bit registers
type reg_array is array(0 to 3) of std_logic_vector(7 downto 0);
signal registers : reg_array := (others => (others => '0'));

begin

    process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if wr_en = '1' and wr_addr /= "00" then
                registers(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process;

    rs1_data <= (others => '0') when rs1_addr = "00"
                else registers(to_integer(unsigned(rs1_addr)));

    rs2_data <= (others => '0') when rs2_addr = "00"
                else registers(to_integer(unsigned(rs2_addr)));

end Behavioral;
