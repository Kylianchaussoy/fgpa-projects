library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;

entity pipelined_cpu is
    Port (
        clk : in std_logic;
        rst : in std_logic
    );
end pipelined_cpu;

architecture Behavioral of pipelined_cpu is

    signal if_pc_out : std_logic_vector(31 downto 0);

    type if_id_reg_type is record
        pc : std_logic_vector(31 downto 0);
    end record;
    signal if_id_reg : if_id_reg_type;

    signal sync_imem_out : std_logic_vector(31 downto 0);
    signal id_instruction_in : std_logic_vector(31 downto 0);
    signal flush_delay : std_logic;

    signal id_rs1_addr  : std_logic_vector(4 downto 0);
    signal id_rs2_addr  : std_logic_vector(4 downto 0);
    signal id_rd_addr   : std_logic_vector(4 downto 0);
    signal id_imm32     : std_logic_vector(31 downto 0);
    signal id_alu_op    : alu_op_t;
    signal id_use_imm   : std_logic;
    signal id_use_pc_alu: std_logic;
    signal id_mem_read  : std_logic;
    signal id_mem_write : std_logic;
    signal id_mem_funct3: std_logic_vector(2 downto 0);
    signal id_reg_wr    : std_logic;
    signal id_wb_sel    : std_logic_vector(1 downto 0);
    signal id_branch_op : branch_op_t;
    signal id_jump      : std_logic;
    signal id_jump_reg  : std_logic;
    signal id_rs1_data  : std_logic_vector(31 downto 0);
    signal id_rs2_data  : std_logic_vector(31 downto 0);

    type id_ex_reg_type is record
        pc          : std_logic_vector(31 downto 0);
        rs1_addr    : std_logic_vector(4 downto 0);
        rs2_addr    : std_logic_vector(4 downto 0);
        rs1_data    : std_logic_vector(31 downto 0);
        rs2_data    : std_logic_vector(31 downto 0);
        rd_addr     : std_logic_vector(4 downto 0);
        imm32       : std_logic_vector(31 downto 0);
        alu_op      : alu_op_t;
        use_imm     : std_logic;
        use_pc_alu  : std_logic;
        mem_read    : std_logic;
        mem_write   : std_logic;
        mem_funct3  : std_logic_vector(2 downto 0);
        reg_wr      : std_logic;
        wb_sel      : std_logic_vector(1 downto 0);
        branch_op   : branch_op_t;
        jump        : std_logic;
        jump_reg    : std_logic;
    end record;
    signal id_ex_reg : id_ex_reg_type;

    signal ex_alu_res     : std_logic_vector(31 downto 0);
    signal ex_branch_taken: std_logic;
    signal ex_branch_addr : std_logic_vector(31 downto 0);
    signal ex_jump_addr   : std_logic_vector(31 downto 0);
    signal ex_full_addr   : std_logic_vector(31 downto 0);
    signal ex_pc_plus4    : std_logic_vector(31 downto 0);

    type ex_mem_reg_type is record
        alu_res    : std_logic_vector(31 downto 0);
        rs2_data   : std_logic_vector(31 downto 0);
        rd_addr    : std_logic_vector(4 downto 0);
        pc_plus4   : std_logic_vector(31 downto 0);
        mem_read   : std_logic;
        mem_write  : std_logic;
        mem_funct3 : std_logic_vector(2 downto 0);
        reg_wr     : std_logic;
        wb_sel     : std_logic_vector(1 downto 0);
    end record;
    signal ex_mem_reg : ex_mem_reg_type;

    signal mem_rd_data : std_logic_vector(31 downto 0);

    type mem_wb_reg_type is record
        alu_res  : std_logic_vector(31 downto 0);
        rd_addr  : std_logic_vector(4 downto 0);
        pc_plus4 : std_logic_vector(31 downto 0);
        reg_wr   : std_logic;
        wb_sel   : std_logic_vector(1 downto 0);
    end record;
    signal mem_wb_reg : mem_wb_reg_type;

    signal wb_wr_data : std_logic_vector(31 downto 0);

    signal pc_next  : std_logic_vector(31 downto 0);
    signal pc_load  : std_logic;
    signal pc_inc   : std_logic;

    signal forward_a : std_logic_vector(1 downto 0);
    signal forward_b : std_logic_vector(1 downto 0);
    signal forwarded_rs1_data : std_logic_vector(31 downto 0);
    signal forwarded_rs2_data : std_logic_vector(31 downto 0);

    signal alu_input_a  : std_logic_vector(31 downto 0);
    signal alu_input_b  : std_logic_vector(31 downto 0);

    signal stall : std_logic;
    signal flush : std_logic;

begin

    pc_inc <= not stall; 

    pc_inst: entity work.pc
        port map (
            clk       => clk,
            rst       => rst,
            inc       => pc_inc,
            load      => pc_load,
            jump_addr => pc_next,
            pc_out    => if_pc_out
        );

    instr_mem_inst: entity work.instruction_memory
        port map (
            clk   => clk,
            en    => not stall,
            addr  => if_pc_out,
            instr => sync_imem_out
        );

    process(clk)
    begin
        if rising_edge(clk) then
            flush_delay <= flush;
            if rst = '1' or flush = '1' then
                if_id_reg.pc <= (others => '0');
            elsif stall = '0' then
                if_id_reg.pc <= if_pc_out;
            end if;
        end if;
    end process;

    id_instruction_in <= NOP when (flush_delay = '1' or rst = '1') else sync_imem_out;

    instruction_decoder_inst: entity work.instruction_decoder
        port map (
            instruction => id_instruction_in,
            rd_addr     => id_rd_addr,
            rs1_addr    => id_rs1_addr,
            rs2_addr    => id_rs2_addr,
            imm32       => id_imm32,
            alu_op      => id_alu_op,
            use_imm     => id_use_imm,
            use_pc_alu  => id_use_pc_alu,
            mem_read    => id_mem_read,
            mem_write   => id_mem_write,
            mem_funct3  => id_mem_funct3,
            reg_wr      => id_reg_wr,
            wb_sel      => id_wb_sel,
            branch_op   => id_branch_op,
            jump        => id_jump,
            jump_reg    => id_jump_reg
        );

    register_file_inst: entity work.register_file
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => mem_wb_reg.reg_wr,
            wr_addr  => mem_wb_reg.rd_addr,
            wr_data  => wb_wr_data,
            rs1_addr => id_rs1_addr,
            rs1_data => id_rs1_data,
            rs2_addr => id_rs2_addr,
            rs2_data => id_rs2_data
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or stall = '1' or flush = '1' then
                id_ex_reg.pc         <= (others => '0');
                id_ex_reg.rs1_addr   <= (others => '0');
                id_ex_reg.rs2_addr   <= (others => '0');
                id_ex_reg.rs1_data   <= (others => '0');
                id_ex_reg.rs2_data   <= (others => '0');
                id_ex_reg.rd_addr    <= (others => '0');
                id_ex_reg.imm32      <= (others => '0');
                id_ex_reg.alu_op     <= ALU_ADD;
                id_ex_reg.use_imm    <= '0';
                id_ex_reg.use_pc_alu <= '0';
                id_ex_reg.mem_read   <= '0';
                id_ex_reg.mem_write  <= '0';
                id_ex_reg.mem_funct3 <= (others => '0');
                id_ex_reg.reg_wr     <= '0';
                id_ex_reg.wb_sel     <= (others => '0');
                id_ex_reg.branch_op  <= NO_BRANCH;
                id_ex_reg.jump       <= '0';
                id_ex_reg.jump_reg   <= '0';
            else
                id_ex_reg.pc         <= if_id_reg.pc;
                id_ex_reg.rs1_addr   <= id_rs1_addr;
                id_ex_reg.rs2_addr   <= id_rs2_addr;
                id_ex_reg.rs1_data   <= id_rs1_data;
                id_ex_reg.rs2_data   <= id_rs2_data;
                id_ex_reg.rd_addr    <= id_rd_addr;
                id_ex_reg.imm32      <= id_imm32;
                id_ex_reg.alu_op     <= id_alu_op;
                id_ex_reg.use_imm    <= id_use_imm;
                id_ex_reg.use_pc_alu <= id_use_pc_alu;
                id_ex_reg.mem_read   <= id_mem_read;
                id_ex_reg.mem_write  <= id_mem_write;
                id_ex_reg.mem_funct3 <= id_mem_funct3;
                id_ex_reg.reg_wr     <= id_reg_wr;
                id_ex_reg.wb_sel     <= id_wb_sel;
                id_ex_reg.branch_op  <= id_branch_op;
                id_ex_reg.jump       <= id_jump;
                id_ex_reg.jump_reg   <= id_jump_reg;
            end if;
        end if;
    end process;

    ex_pc_plus4   <= std_logic_vector(unsigned(id_ex_reg.pc) + 4);
    ex_branch_addr <= std_logic_vector(unsigned(id_ex_reg.pc) + unsigned(id_ex_reg.imm32));
    ex_full_addr  <= std_logic_vector(unsigned(forwarded_rs1_data) + unsigned(id_ex_reg.imm32));
    ex_jump_addr  <= ex_full_addr(31 downto 1) & '0';

    flush <= id_ex_reg.jump or id_ex_reg.jump_reg or ex_branch_taken;
    pc_load <= flush; 
    pc_next <= ex_jump_addr   when id_ex_reg.jump_reg = '1'  else
               ex_branch_addr when id_ex_reg.jump     = '1'  else
               ex_branch_addr when ex_branch_taken    = '1'  else
               ex_pc_plus4;

    forwarding_unit_inst: entity work.forwarding_unit
        port map (
            id_ex_rs1_addr   => id_ex_reg.rs1_addr,
            id_ex_rs2_addr   => id_ex_reg.rs2_addr,
            ex_mem_rd_addr   => ex_mem_reg.rd_addr,
            ex_mem_reg_write => ex_mem_reg.reg_wr,
            mem_wb_rd_addr   => mem_wb_reg.rd_addr,
            mem_wb_reg_write => mem_wb_reg.reg_wr,
            forward_a        => forward_a,
            forward_b        => forward_b
        );

    with forward_a select
        forwarded_rs1_data <=
            id_ex_reg.rs1_data when "00",  
            wb_wr_data         when "01",
            ex_mem_reg.alu_res when "10",
            (others => '0')    when others;

    with forward_b select
        forwarded_rs2_data <=
            id_ex_reg.rs2_data when "00",
            wb_wr_data         when "01",
            ex_mem_reg.alu_res when "10",
            (others => '0')    when others;

    alu_input_a <= id_ex_reg.pc    when id_ex_reg.use_pc_alu = '1' else forwarded_rs1_data;
    alu_input_b <= id_ex_reg.imm32 when id_ex_reg.use_imm    = '1' else forwarded_rs2_data;
    
    hazard_unit_inst: entity work.hazard_unit
        port map (
            id_ex_mem_read => id_ex_reg.mem_read,
            id_ex_rd_addr  => id_ex_reg.rd_addr,
            if_id_rs1_addr => id_rs1_addr,
            if_id_rs2_addr => id_rs2_addr,
            stall          => stall
        );

    alu_inst: entity work.alu
        port map (
            a      => alu_input_a,
            b      => alu_input_b,
            alu_op => id_ex_reg.alu_op,
            res    => ex_alu_res
        );

    branch_unit_inst: entity work.branch_unit
        port map (
            a            => forwarded_rs1_data,
            b            => forwarded_rs2_data,
            branch_op    => id_ex_reg.branch_op,
            branch_taken => ex_branch_taken
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ex_mem_reg.alu_res    <= (others => '0');
                ex_mem_reg.rs2_data   <= (others => '0');
                ex_mem_reg.rd_addr    <= (others => '0');
                ex_mem_reg.pc_plus4   <= (others => '0');
                ex_mem_reg.mem_read   <= '0';
                ex_mem_reg.mem_write  <= '0';
                ex_mem_reg.mem_funct3 <= (others => '0');
                ex_mem_reg.reg_wr     <= '0';
                ex_mem_reg.wb_sel     <= (others => '0');
            else
                ex_mem_reg.alu_res    <= ex_alu_res;
                ex_mem_reg.rs2_data   <= forwarded_rs2_data;
                ex_mem_reg.rd_addr    <= id_ex_reg.rd_addr;
                ex_mem_reg.pc_plus4   <= ex_pc_plus4;
                ex_mem_reg.mem_read   <= id_ex_reg.mem_read;
                ex_mem_reg.mem_write  <= id_ex_reg.mem_write;
                ex_mem_reg.mem_funct3 <= id_ex_reg.mem_funct3;
                ex_mem_reg.reg_wr     <= id_ex_reg.reg_wr;
                ex_mem_reg.wb_sel     <= id_ex_reg.wb_sel;
            end if;
        end if;
    end process;

    data_memory_inst: entity work.data_memory
        port map (
            clk       => clk,
            mem_read  => ex_mem_reg.mem_read,
            mem_write => ex_mem_reg.mem_write,
            funct3    => ex_mem_reg.mem_funct3,
            addr      => ex_mem_reg.alu_res,
            wr_data   => ex_mem_reg.rs2_data,
            rd_data   => mem_rd_data
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mem_wb_reg.alu_res  <= (others => '0');
                mem_wb_reg.rd_addr  <= (others => '0');
                mem_wb_reg.pc_plus4 <= (others => '0');
                mem_wb_reg.reg_wr   <= '0';
                mem_wb_reg.wb_sel   <= (others => '0');
            else
                mem_wb_reg.alu_res  <= ex_mem_reg.alu_res;
                mem_wb_reg.rd_addr  <= ex_mem_reg.rd_addr;
                mem_wb_reg.pc_plus4 <= ex_mem_reg.pc_plus4;
                mem_wb_reg.reg_wr   <= ex_mem_reg.reg_wr;
                mem_wb_reg.wb_sel   <= ex_mem_reg.wb_sel;
            end if;
        end if;
    end process;

    wb_wr_data <= mem_wb_reg.alu_res  when mem_wb_reg.wb_sel = "00" else
                  mem_rd_data         when mem_wb_reg.wb_sel = "01" else
                  mem_wb_reg.pc_plus4 when mem_wb_reg.wb_sel = "10" else
                  (others => '0');

end Behavioral;
