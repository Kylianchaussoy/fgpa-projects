library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
package rv32i_pkg is
    type alu_op_t is (ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_SLL, ALU_SRL, ALU_SRA, ALU_SLT, ALU_SLTU, ALU_COPY_B, ALU_NONE);

    type branch_op_t is (NO_BRANCH, BEQ, BNE, BLT, BGE, BLTU, BGEU);

    constant OP_R_TYPE  : std_logic_vector(6 downto 0) := "0110011";
    constant OP_I_TYPE  : std_logic_vector(6 downto 0) := "0010011";
    constant OP_LOAD    : std_logic_vector(6 downto 0) := "0000011";
    constant OP_STORE   : std_logic_vector(6 downto 0) := "0100011";
    constant OP_BRANCH  : std_logic_vector(6 downto 0) := "1100011";
    constant OP_JAL     : std_logic_vector(6 downto 0) := "1101111";
    constant OP_JALR    : std_logic_vector(6 downto 0) := "1100111";
    constant OP_LUI     : std_logic_vector(6 downto 0) := "0110111";
    constant OP_AUIPC   : std_logic_vector(6 downto 0) := "0010111";
    constant OP_ECALL   : std_logic_vector(6 downto 0) := "1110011";
    constant OP_FENCE   : std_logic_vector(6 downto 0) := "0001111";
 
    constant F3_ADD_SUB : std_logic_vector(2 downto 0) := "000";
    constant F3_SLL     : std_logic_vector(2 downto 0) := "001";
    constant F3_SLT     : std_logic_vector(2 downto 0) := "010";
    constant F3_SLTU    : std_logic_vector(2 downto 0) := "011";
    constant F3_XOR     : std_logic_vector(2 downto 0) := "100";
    constant F3_SRL_SRA : std_logic_vector(2 downto 0) := "101";
    constant F3_OR      : std_logic_vector(2 downto 0) := "110";
    constant F3_AND     : std_logic_vector(2 downto 0) := "111";
 
    constant F3_LB  : std_logic_vector(2 downto 0) := "000";
    constant F3_LH  : std_logic_vector(2 downto 0) := "001";
    constant F3_LW  : std_logic_vector(2 downto 0) := "010";
    constant F3_LBU : std_logic_vector(2 downto 0) := "100";
    constant F3_LHU : std_logic_vector(2 downto 0) := "101";
 
    constant F3_SB  : std_logic_vector(2 downto 0) := "000";
    constant F3_SH  : std_logic_vector(2 downto 0) := "001";
    constant F3_SW  : std_logic_vector(2 downto 0) := "010";

    constant NOP :std_logic_vector(31 downto 0) := x"00000013";

end package rv32i_pkg;
