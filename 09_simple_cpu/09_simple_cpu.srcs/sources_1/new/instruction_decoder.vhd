----------------------------------------------------------------------------------
--  Instruction Decoder
--  Takes a 16-bit instruction word and generates all
--  control signals for the datapath.
--
--  Instruction format:
--    [15:12] OPCODE  (4 bits)
--    [11:10] Rd      (destination register)
--    [9:8]   Rs1     (source register 1)
--    [7:4]   Rs2     (source register 2, lower 2 bits = [5:4])
--    [7:0]   Imm8    (8-bit immediate value)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.simple_cpu_pkg.all;

entity instruction_decoder is
 Port ( 
    instruction : in std_logic_vector(15 downto 0);

    rd_addr : out std_logic_vector(1 downto 0);
    rs1_addr : out std_logic_vector(1 downto 0);
    rs2_addr : out std_logic_vector(1 downto 0);
    imm8 : out std_logic_vector(7 downto 0);

    alu_op : out std_logic_vector(2 downto 0);

    reg_wr : out std_logic;
    use_imm : out std_logic;
    pc_inc : out std_logic;
    pc_load : out std_logic;
    br_eq : out std_logic;
    halt : out std_logic
 );
end instruction_decoder;

architecture Behavioral of instruction_decoder is

begin

    process(instruction)
    begin
        rd_addr <= instruction(11 downto 10);
        rs1_addr <= instruction(9 downto 8);
        rs2_addr <= instruction(5 downto 4);
        imm8 <= instruction(7 downto 0);
        alu_op <= "000";
        reg_wr <= '0';
        use_imm <= '0';
        pc_inc <= '1';
        pc_load <= '0';
        br_eq <= '0';
        halt <= '0';

        case instruction(15 downto 12) is
    
            when OP_ADD =>
                alu_op <= ALU_ADD;
                reg_wr <= '1';

            when OP_SUB =>
                alu_op <= ALU_SUB;
                reg_wr <= '1';

            when OP_AND =>
                alu_op <= ALU_AND;
                reg_wr <= '1';

            when OP_OR =>
                alu_op <= ALU_OR;
                reg_wr <= '1';

            when OP_XOR =>
                alu_op <= ALU_XOR;
                reg_wr <= '1';

            when OP_NOT =>
                alu_op <= ALU_NOT;
                reg_wr <= '1';

            when OP_LDI =>
                rs1_addr <= "00"; 
                alu_op  <= ALU_ADD;
                reg_wr  <= '1';
                use_imm <= '1';

            when OP_MOV =>
                rs2_addr <= "00"; 
                alu_op <= ALU_ADD;
                reg_wr <= '1';

            when OP_JMP =>
                pc_inc  <= '0';
                pc_load <= '1';

            when OP_BEQ =>
                alu_op <= ALU_SUB;
                rs1_addr <= instruction(11 downto 10);
                rs2_addr <= instruction(9 downto 8);
                br_eq  <= '1';
                pc_inc <= '1';

            when OP_HLT =>
                pc_inc <= '0';
                halt   <= '1';

            when others =>
                null;

        end case;
    end process;


end Behavioral;
