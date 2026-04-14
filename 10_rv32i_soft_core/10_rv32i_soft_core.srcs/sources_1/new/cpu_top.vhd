library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;

entity cpu_top is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    
    -- dbg signals
    dgb_pc_out : out std_logic_vector(31 downto 0);
    dbg_pc_next : out std_logic_vector(31 downto 0);
    
    dbg_branch_addr : out std_logic_vector(31 downto 0);
    dbg_jump_addr : out std_logic_vector(31 downto 0);
    dbg_pc_load : out std_logic;
    dbg_pc_inc : out std_logic;

    dbg_instruction : out std_logic_vector(31 downto 0);
    dbg_rd_addr : out std_logic_vector(4 downto 0);
    dbg_rs1_addr : out std_logic_vector(4 downto 0);
    dbg_rs2_addr : out std_logic_vector(4 downto 0);
    dbg_rs1_data : out std_logic_vector(31 downto 0);
    dbg_rs2_data : out std_logic_vector(31 downto 0);
    dbg_alu_b : out std_logic_vector(31 downto 0);
    dbg_imm32 : out std_logic_vector(31 downto 0);

    dbg_alu_op : out alu_op_t;
    dbg_alu_res : out std_logic_vector(31 downto 0);

    dbg_wr_data  : out std_logic_vector(31 downto 0);
    dbg_wb_sel : out std_logic_vector(1 downto 0);

    dbg_use_imm : out std_logic;
    dbg_mem_read : out std_logic;
    dbg_mem_write : out std_logic;
    dbg_mem_funct3 : out std_logic_vector(2 downto 0);
    dbg_reg_wr : out std_logic;
    dbg_branch_op : out branch_op_t;
    dbg_jump : out std_logic;
    dbg_jump_reg : out std_logic;
    dbg_mem_rd_data : out std_logic_vector(31 downto 0);
    dbg_branch_taken : out std_logic
  );
end cpu_top;

architecture Behavioral of cpu_top is
    signal pc_out : std_logic_vector(31 downto 0);
    signal pc_next : std_logic_vector(31 downto 0);
    signal pc_plus4 : std_logic_vector(31 downto 0);
    signal branch_addr : std_logic_vector(31 downto 0);
    signal full_addr : std_logic_vector(31 downto 0);
    signal jump_addr : std_logic_vector(31 downto 0);
    signal pc_load : std_logic;
    signal pc_inc : std_logic;
 
    signal instruction : std_logic_vector(31 downto 0);
 
    signal rs1_addr : std_logic_vector(4 downto 0);
    signal rs2_addr : std_logic_vector(4 downto 0);
    signal rd_addr : std_logic_vector(4 downto 0);
    signal imm32 : std_logic_vector(31 downto 0);
    signal alu_op : alu_op_t;
    signal use_imm : std_logic;
    signal use_pc_alu : std_logic;
    signal mem_read : std_logic;
    signal mem_write : std_logic;
    signal mem_funct3 : std_logic_vector(2 downto 0);
    signal reg_wr : std_logic;
    signal wb_sel : std_logic_vector(1 downto 0); -- 00=ALU, 01=MEM, 10=PC+4
    signal branch_op : branch_op_t;
    signal jump : std_logic;   -- JAL
    signal jump_reg : std_logic;   -- JALR
 
    signal rs1_data : std_logic_vector(31 downto 0);
    signal rs2_data : std_logic_vector(31 downto 0);
    signal wr_data  : std_logic_vector(31 downto 0);
 
    signal alu_a : std_logic_vector(31 downto 0);
    signal alu_b : std_logic_vector(31 downto 0);
    signal alu_res : std_logic_vector(31 downto 0);
 
    signal mem_rd_data : std_logic_vector(31 downto 0);
 
    signal branch_taken : std_logic;

begin

    pc_plus4 <= std_logic_vector(unsigned(pc_out) + 4);
    branch_addr <= std_logic_vector(unsigned(pc_out) + unsigned(imm32));
 
    -- JARL
    full_addr <= std_logic_vector(unsigned(rs1_data) + unsigned(imm32));
    jump_addr <= full_addr(31 downto 1) & '0';
 
    pc_next <= jump_addr   when jump_reg    = '1'             else
               branch_addr when jump        = '1'             else
               branch_addr when branch_taken = '1'            else
               pc_plus4;
 
    pc_inc  <= '1';
    pc_load <= jump or jump_reg or branch_taken;
    
    alu_a <= pc_out when use_pc_alu = '1' else rs1_data;
    alu_b <= imm32 when use_imm = '1' else rs2_data;
 
    wr_data <= alu_res    when wb_sel = "00" else
               mem_rd_data when wb_sel = "01" else
               pc_plus4   when wb_sel = "10" else
               imm32;

    instr_mem_inst: entity work.instruction_memory
        port map (
            addr  => pc_out,
            instr => instruction
        );

    alu_inst: entity work.alu
        port map (
            a      => alu_a,
            b      => alu_b,
            alu_op => alu_op,
            res    => alu_res
        );

    pc_inst: entity work.pc
        port map (
            clk       => clk,
            rst       => rst,
            inc       => pc_inc,
            load      => pc_load,
            jump_addr => pc_next,
            pc_out    => pc_out
        );

    register_file_inst: entity work.register_file
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => reg_wr,
            wr_addr  => rd_addr,
            wr_data  => wr_data,
            rs1_addr => rs1_addr,
            rs1_data => rs1_data,
            rs2_addr => rs2_addr,
            rs2_data => rs2_data
        );

    branch_unit_inst: entity work.branch_unit
        port map (
            a            => rs1_data,
            b            => rs2_data,
            branch_op    => branch_op,
            branch_taken => branch_taken
        );

    instruction_decoder_inst: entity work.instruction_decoder
        port map (
            instruction => instruction,
            rd_addr     => rd_addr,
            rs1_addr    => rs1_addr,
            rs2_addr    => rs2_addr,
            imm32       => imm32,
            alu_op      => alu_op,
            use_imm     => use_imm,
            use_pc_alu  => use_pc_alu,
            mem_read    => mem_read,
            mem_write   => mem_write,
            mem_funct3  => mem_funct3,
            reg_wr      => reg_wr,
            wb_sel      => wb_sel,
            branch_op   => branch_op,
            jump        => jump,
            jump_reg    => jump_reg
        );

    data_memory_inst: entity work.data_memory
        port map (
            clk       => clk,
            mem_read  => mem_read,
            mem_write => mem_write,
            funct3    => mem_funct3,
            addr      => alu_res,
            wr_data   => rs2_data,
            rd_data   => mem_rd_data
        );

      dgb_pc_out       <= pc_out;
      dbg_pc_next      <= pc_next;
      dbg_branch_addr  <= branch_addr;
      dbg_jump_addr    <= jump_addr;
      dbg_pc_load      <= pc_load;
      dbg_pc_inc       <= pc_inc;
      dbg_instruction  <= instruction;
      dbg_rs1_addr     <= rs1_addr;
      dbg_rs2_addr     <= rs2_addr;
      dbg_rd_addr      <= rd_addr;
      dbg_imm32        <= imm32;
      dbg_alu_op       <= alu_op;
      dbg_use_imm      <= use_imm;
      dbg_mem_read     <= mem_read;
      dbg_mem_write    <= mem_write;
      dbg_mem_funct3   <= mem_funct3;
      dbg_reg_wr       <= reg_wr;
      dbg_wb_sel       <= wb_sel;
      dbg_branch_op    <= branch_op;
      dbg_jump         <= jump;
      dbg_jump_reg     <= jump_reg;
      dbg_rs1_data     <= rs1_data;
      dbg_rs2_data     <= rs2_data;
      dbg_wr_data      <= wr_data;
      dbg_alu_b        <= alu_b;
      dbg_alu_res      <= alu_res;
      dbg_mem_rd_data  <= mem_rd_data;
      dbg_branch_taken <= branch_taken;

end Behavioral;
