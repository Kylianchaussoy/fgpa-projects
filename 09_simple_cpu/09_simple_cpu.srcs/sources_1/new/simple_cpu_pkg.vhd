library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
package simple_cpu_pkg is
    -- ALU opcodes
    constant ALU_ADD : std_logic_vector(2 downto 0) := "000";
    constant ALU_SUB : std_logic_vector(2 downto 0) := "001";
    constant ALU_AND : std_logic_vector(2 downto 0) := "010";
    constant ALU_OR : std_logic_vector(2 downto 0) := "011";
    constant ALU_XOR : std_logic_vector(2 downto 0) := "100";
    constant ALU_NOT : std_logic_vector(2 downto 0) := "101";

    -- Opcode definitions
    constant OP_ADD : std_logic_vector(3 downto 0) := "0000";
    constant OP_SUB : std_logic_vector(3 downto 0) := "0001";
    constant OP_AND : std_logic_vector(3 downto 0) := "0010";
    constant OP_OR  : std_logic_vector(3 downto 0) := "0011";
    constant OP_XOR : std_logic_vector(3 downto 0) := "0100";
    constant OP_NOT : std_logic_vector(3 downto 0) := "0101";
    constant OP_LDI : std_logic_vector(3 downto 0) := "0110";  -- Load Immediate
    constant OP_MOV : std_logic_vector(3 downto 0) := "0111";  -- Move register
    constant OP_JMP : std_logic_vector(3 downto 0) := "1000";  -- Unconditional jump
    constant OP_BEQ : std_logic_vector(3 downto 0) := "1001";  -- Branch if equal
    constant OP_HLT : std_logic_vector(3 downto 0) := "1111";  -- Halt

end package simple_cpu_pkg;
