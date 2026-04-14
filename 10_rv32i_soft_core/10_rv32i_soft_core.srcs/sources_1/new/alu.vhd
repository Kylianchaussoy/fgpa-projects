library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;

entity alu is
    Generic (XLEN : integer := 32);
    Port (
    a, b : in std_logic_vector(XLEN-1 downto 0);
    alu_op : in alu_op_t;
    res : out std_logic_vector(XLEN-1 downto 0)
    );
end alu;

architecture Behavioral of alu is
begin

process(a, b, alu_op)
    variable v_res : unsigned(XLEN-1 downto 0);
    variable shift_amt : integer;
begin
    shift_amt := to_integer(unsigned(b(4 downto 0)));
    v_res := (others => '0');

    case alu_op is
        when ALU_ADD => v_res := unsigned(a) + unsigned(b);
        when ALU_SUB => v_res := unsigned(a) - unsigned(b);
        when ALU_AND => v_res := unsigned(a and b);
        when ALU_OR => v_res := unsigned(a or b);
        when ALU_XOR => v_res := unsigned(a xor b);
        when ALU_SLL => v_res := shift_left(unsigned(a), shift_amt);
        when ALU_SRL => v_res := shift_right(unsigned(a), shift_amt);
        when ALU_SRA => v_res := unsigned(shift_right(signed(a), shift_amt));
        when ALU_SLT =>
            if signed(a) < signed(b) then
                v_res := (31 downto 1 => '0') & '1';
            else
                v_res := (others => '0');
            end if;
        when ALU_SLTU =>
            if unsigned(a) < unsigned(b) then
                v_res := (31 downto 1 => '0') & '1';
            else
                v_res := (others => '0');
            end if;
        when others => v_res := (others => '0');
    end case;
    
    res <= std_logic_vector(v_res);
end process;

end Behavioral;
