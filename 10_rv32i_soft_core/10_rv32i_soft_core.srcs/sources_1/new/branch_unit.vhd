library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;

entity branch_unit is
    Generic (XLEN : integer := 32);
    Port (
        a : in  std_logic_vector(XLEN-1 downto 0);
        b : in  std_logic_vector(XLEN-1 downto 0);
        branch_op : in branch_op_t;
        branch_taken : out std_logic
    );
end entity branch_unit;

architecture rtl of branch_unit is
begin
    process(a, b, branch_op)
    begin
        branch_taken <= '0';
        
        case branch_op is
            when BEQ => if signed(a) = signed(b)  then branch_taken <= '1'; end if;
            when BNE => if signed(a) /= signed(b) then branch_taken <= '1'; end if;
            when BLT => if signed(a) < signed(b)  then branch_taken <= '1'; end if;
            when BGE => if signed(a) >= signed(b) then branch_taken <= '1'; end if;
            when BLTU => if unsigned(a) < unsigned(b) then branch_taken <= '1'; end if;
            when BGEU => if unsigned(a) >= unsigned(b) then branch_taken <= '1'; end if;
            when others => branch_taken <= '0';
        end case;
        
    end process;
end architecture rtl;
