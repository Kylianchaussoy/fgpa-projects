library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;

entity instruction_decoder is
    Port (
        instruction  : in  std_logic_vector(31 downto 0);

        rd_addr : out std_logic_vector(4 downto 0);
        rs1_addr : out std_logic_vector(4 downto 0);
        rs2_addr : out std_logic_vector(4 downto 0);

        imm32 : out std_logic_vector(31 downto 0);

        alu_op : out alu_op_t;
        use_imm : out std_logic;
        use_pc_alu : out std_logic;

        mem_read : out std_logic;
        mem_write : out std_logic;
        mem_funct3 : out std_logic_vector(2 downto 0);

        reg_wr : out std_logic;
        wb_sel : out std_logic_vector(1 downto 0);

        branch_op : out branch_op_t;
        jump : out std_logic;
        jump_reg : out std_logic
    );
end entity instruction_decoder;

architecture Behavioral of instruction_decoder is

    alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);
    alias funct3 : std_logic_vector(2 downto 0) is instruction(14 downto 12);
    alias funct7 : std_logic_vector(6 downto 0) is instruction(31 downto 25);

    signal imm_i : std_logic_vector(31 downto 0);
    signal imm_s : std_logic_vector(31 downto 0);
    signal imm_b : std_logic_vector(31 downto 0);
    signal imm_u : std_logic_vector(31 downto 0);
    signal imm_j : std_logic_vector(31 downto 0);

begin

    imm_i <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);
    imm_s <= (31 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7);
    imm_b <= (31 downto 13 => instruction(31)) & instruction(31) &
             instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';
    imm_u <= instruction(31 downto 12) & (11 downto 0 => '0');
    imm_j <= (31 downto 21 => instruction(31)) & instruction(31) &
             instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';

    rd_addr <= instruction(11 downto 7);
    rs1_addr <= instruction(19 downto 15);
    rs2_addr <= instruction(24 downto 20);

    process(instruction, imm_i, imm_s, imm_b, imm_u, imm_j, opcode, funct3, funct7)
    begin
        alu_op <= ALU_NONE;
        use_imm <= '0';
        use_pc_alu <= '0';
        mem_read <= '0';
        mem_write <= '0';
        mem_funct3 <= "000";
        reg_wr <= '0';
        wb_sel <= "00";
        branch_op <= NO_BRANCH;
        jump <= '0';
        jump_reg <= '0';
        imm32 <= (others => '0');

        case opcode is

            when OP_R_TYPE =>
                reg_wr <= '1';
                wb_sel <= "00";
                use_imm <= '0';
                imm32 <= (others => '0');

                case funct3 is
                    when F3_ADD_SUB =>
                        if funct7(5) = '0' then
                            alu_op <= ALU_ADD;
                        else
                            alu_op <= ALU_SUB;
                        end if;
                    when F3_SLT => alu_op <= ALU_SLT;
                    when F3_SLTU => alu_op <= ALU_SLTU;
                    when F3_AND => alu_op <= ALU_AND;
                    when F3_OR => alu_op <= ALU_OR;
                    when F3_XOR => alu_op <= ALU_XOR;
                    when F3_SLL => alu_op <= ALU_SLL;
                    when F3_SRL_SRA =>
                        if funct7(5) = '0' then
                            alu_op <= ALU_SRL;
                        else
                            alu_op <= ALU_SRA;
                        end if;
                    when others => alu_op <= ALU_NONE;
                end case;

            when OP_I_TYPE =>
                reg_wr <= '1';
                use_imm <= '1';
                wb_sel <= "00";
                imm32 <= imm_i;

                case funct3 is
                    when F3_ADD_SUB => alu_op <= ALU_ADD;
                    when F3_SLL => alu_op <= ALU_SLL;
                    when F3_XOR => alu_op <= ALU_XOR;
                    when F3_SLT => alu_op <= ALU_SLT;
                    when F3_SLTU => alu_op <= ALU_SLTU;
                    when F3_SRL_SRA =>
                        if funct7(5) = '0' then
                            alu_op <= ALU_SRL;
                        else
                            alu_op <= ALU_SRA;
                        end if;
                    when F3_OR      => alu_op <= ALU_OR;
                    when F3_AND     => alu_op <= ALU_AND;
                    when others => alu_op <= ALU_NONE;
                end case;

            when OP_LOAD =>
                reg_wr <= '1';
                use_imm <= '1';
                mem_read <= '1';
                alu_op <= ALU_ADD;
                imm32 <= imm_i;
                wb_sel <= "01";
                mem_funct3 <= funct3;

            when OP_STORE =>
                reg_wr <= '0';
                use_imm <= '1';
                mem_write <= '1';
                alu_op <= ALU_ADD;
                imm32 <= imm_s;
                mem_funct3 <= funct3;

            when OP_BRANCH =>
                reg_wr <= '0';
                use_imm <= '0';
                imm32 <= imm_b;
                alu_op <= ALU_NONE;

                case funct3 is
                    when "000" => branch_op <= BEQ;
                    when "001" => branch_op <= BNE;
                    when "100" => branch_op <= BLT;
                    when "101" => branch_op <= BGE;
                    when "110" => branch_op <= BLTU;
                    when "111" => branch_op <= BGEU;
                    when others => branch_op <= NO_BRANCH;
                end case;

            when OP_JAL =>
                reg_wr <= '1';
                jump <= '1';
                jump_reg <= '0';
                imm32 <= imm_j;
                wb_sel <= "10";

            when OP_JALR =>
                reg_wr <= '1';
                use_imm <= '1';
                jump <= '1';
                jump_reg <= '1';
                alu_op <= ALU_ADD;
                imm32 <= imm_i;
                wb_sel <= "10";

            when OP_LUI =>
                reg_wr <= '1';
                imm32 <= imm_u;
                wb_sel <= "11";

            when OP_AUIPC =>
                reg_wr <= '1';
                use_imm <= '1';
                use_pc_alu <= '1';
                alu_op <= ALU_ADD;
                imm32 <= imm_u;
                wb_sel <= "00";

            when others =>
                null;
        end case;

    end process;

end architecture Behavioral;
