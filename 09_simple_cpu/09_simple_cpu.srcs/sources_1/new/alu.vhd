----------------------------------------------------------------------------------
-- ALU
-- Supports: ADD, SUB, AND, OR, XOR, NOT
-- 8-bit operands, 8-bit result + flags
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.simple_cpu_pkg.all;

entity alu is
  Port (
    a : in std_logic_vector(7 downto 0);
    b : in std_logic_vector(7 downto 0);
    alu_op : in std_logic_vector(2 downto 0);
    res : out std_logic_vector(7 downto 0);
    zero : out std_logic;
    carry : out std_logic;
    negative : out std_logic
  );
end alu;

architecture Behavioral of alu is
signal s_res : std_logic_vector(8 downto 0); -- 9 bit for carry

begin

res <= s_res(7 downto 0);
carry <= s_res(8);
zero <= '1' when s_res(7 downto 0) = "00000000" else '0';
negative <= s_res(7);

process(a, b, alu_op)
variable tmp : std_logic_vector(8 downto 0);
begin
    case alu_op is

        when ALU_ADD =>
            tmp := std_logic_vector(('0' & unsigned(a)) + ('0' & unsigned(b)));

        when ALU_SUB =>
            tmp := std_logic_vector(('0' & unsigned(a)) - ('0' & unsigned(b)));

        when ALU_AND =>
            tmp(7 downto 0) := a and b;
            tmp(8) := '0';

        when ALU_OR =>
            tmp(7 downto 0) := a or b;
            tmp(8) := '0';

        when ALU_XOR =>
            tmp(7 downto 0) := a xor b;
            tmp(8) := '0';

        when ALU_NOT =>
            tmp(7 downto 0) := not a;
            tmp(8) := '0';

        when others =>
            tmp := (others => '0');
    end case;
    
    s_res <= tmp;
end process;

end Behavioral;
