----------------------------------------------------------------------------------
--  Simple CPU — Top Level
--  Integrates: ALU, Register File, Program Counter,
--              Instruction Decoder, and Instruction Memory ROM
--
--  Pipeline: Single-cycle (fetch -> decode -> execute, in 1 CLK)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.simple_cpu_pkg.all;

entity cpu_top is
    Port (
        clk : in  std_logic;
        rst : in  std_logic;

        -- debug outputs
        dbg_pc : out std_logic_vector(7 downto 0);
        dbg_r1 : out std_logic_vector(7 downto 0);
        dbg_r2 : out std_logic_vector(7 downto 0);
        dbg_alu : out std_logic_vector(7 downto 0);
        halted : out std_logic
    );
end cpu_top;

architecture Structural of cpu_top is

signal pc_out : std_logic_vector(7 downto 0);
signal pc_inc : std_logic;
signal pc_load : std_logic;
signal halt : std_logic;
signal instr_word : std_logic_vector(15 downto 0);
signal rd_addr : std_logic_vector(1 downto 0);
signal rs1_addr : std_logic_vector(1 downto 0);
signal rs2_addr : std_logic_vector(1 downto 0);
signal imm8 : std_logic_vector(7 downto 0);
signal alu_op : std_logic_vector(2 downto 0);
signal reg_wr : std_logic;
signal use_imm : std_logic;
signal br_eq : std_logic;
signal rs1_data : std_logic_vector(7 downto 0);
signal rs2_data : std_logic_vector(7 downto 0);
signal alu_b : std_logic_vector(7 downto 0);
signal alu_res : std_logic_vector(7 downto 0);
signal alu_zero : std_logic;
signal alu_carry : std_logic;
signal alu_neg : std_logic;
signal branch_taken : std_logic;
signal final_pc_inc : std_logic;
signal final_pc_ld : std_logic;

begin

    instr_word <= instr_mem(to_integer(unsigned(pc_out)));

    branch_taken <= br_eq and alu_zero;

    final_pc_ld <= pc_load or branch_taken;
    final_pc_inc <= pc_inc and not (pc_load or branch_taken);

    alu_inst : entity work.alu
        port map(
            a => rs1_data,
            b => alu_b,
            alu_op => alu_op,
            res => alu_res,
            zero => alu_zero,
            carry => alu_carry,
            negative => alu_neg
        );
    alu_b <= imm8 when use_imm = '1' else rs2_data;

    register_file_inst : entity work.register_file
        port map(
            clk => clk,
            rst => rst,
            wr_en => reg_wr,
            wr_addr => rd_addr,
            wr_data => alu_res,
            rs1_addr => rs1_addr,
            rs1_data => rs1_data,
            rs2_addr => rs2_addr,
            rs2_data => rs2_data
        );

    instruction_decoder_inst: entity work.instruction_decoder
        port map (
            instruction => instr_word,
            rd_addr => rd_addr,
            rs1_addr => rs1_addr,
            rs2_addr => rs2_addr,
            imm8 => imm8,
            alu_op => alu_op,
            reg_wr => reg_wr,
            use_imm => use_imm,
            pc_inc => pc_inc,
            pc_load => pc_load,
            br_eq => br_eq,
            halt => halt
        );

    program_counter_inst: entity work.program_counter
        port map (
            clk => clk,
            rst => rst,
            inc => final_pc_inc,
            load => final_pc_ld,
            halt => halt,
            jump_addr => imm8,
            pc_out => pc_out
        );

    dbg_pc <= pc_out;
    dbg_alu <= alu_res;
    dbg_r1 <= rs1_data;
    dbg_r2 <= rs2_data;
    halted <= halt;

end Structural;
