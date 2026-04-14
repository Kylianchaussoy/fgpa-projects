library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;


entity cpu_top_tb is
--  Port ( );
end cpu_top_tb;

architecture Behavioral of cpu_top_tb is
    signal clk: std_logic;
    signal rst: std_logic;
    signal jump : std_logic;
    signal jump_reg : std_logic;
    signal branch_taken : std_logic;
    signal pc_load : std_logic;
    signal pc_out : std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);
    signal pc_next : std_logic_vector(31 downto 0);
    signal pc_plus4 : std_logic_vector(31 downto 0);
    signal branch_addr : std_logic_vector(31 downto 0);
    signal full_addr : std_logic_vector(31 downto 0);
    signal jump_addr : std_logic_vector(31 downto 0);
    signal pc_inc : std_logic;
    signal rs1_addr : std_logic_vector(4 downto 0);
    signal rs2_addr : std_logic_vector(4 downto 0);
    signal rd_addr : std_logic_vector(4 downto 0);
    signal imm32 : std_logic_vector(31 downto 0);
    signal alu_op : alu_op_t;
    signal use_imm : std_logic;
    signal mem_read : std_logic;
    signal mem_write : std_logic;
    signal mem_funct3 : std_logic_vector(2 downto 0);
    signal reg_wr : std_logic;
    signal wb_sel : std_logic_vector(1 downto 0);
    signal branch_op : branch_op_t;
    signal rs1_data : std_logic_vector(31 downto 0);
    signal rs2_data : std_logic_vector(31 downto 0);
    signal wr_data  : std_logic_vector(31 downto 0);
    signal alu_b : std_logic_vector(31 downto 0);
    signal alu_res : std_logic_vector(31 downto 0);
    signal mem_rd_data : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

begin

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

cpu_top_inst: entity work.cpu_top
port map (
  clk              => clk,
  rst              => rst,
  dgb_pc_out       => pc_out,
  dbg_pc_next      => pc_next,
  dbg_branch_addr  => branch_addr,
  dbg_jump_addr    => jump_addr,
  dbg_pc_load      => pc_load,
  dbg_pc_inc       => pc_inc,
  dbg_instruction  => instruction,
  dbg_rs1_addr     => rs1_addr,
  dbg_rs2_addr     => rs2_addr,
  dbg_rd_addr      => rd_addr,
  dbg_imm32        => imm32,
  dbg_alu_op       => alu_op,
  dbg_use_imm      => use_imm,
  dbg_mem_read     => mem_read,
  dbg_mem_write    => mem_write,
  dbg_mem_funct3   => mem_funct3,
  dbg_reg_wr       => reg_wr,
  dbg_wb_sel       => wb_sel,
  dbg_branch_op    => branch_op,
  dbg_jump         => jump,
  dbg_jump_reg     => jump_reg,
  dbg_rs1_data     => rs1_data,
  dbg_rs2_data     => rs2_data,
  dbg_wr_data      => wr_data,
  dbg_alu_b        => alu_b,
  dbg_alu_res      => alu_res,
  dbg_mem_rd_data  => mem_rd_data,
  dbg_branch_taken => branch_taken
);

process
begin
    wait;

end process;


end Behavioral;
