library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    Port (
        clk   : in std_logic;
        en    : in std_logic;
        addr  : in  std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is

    type rom_t is array (0 to 127) of std_logic_vector(31 downto 0);

    -- constant ROM : rom_t := (

    --     0  => x"00000013",   -- NOP (ADDI x0, x0, 0)

    --     -- U-TYPE
    --     1  => x"000012B7",   -- LUI x5, 0x1
    --     2  => x"DEAD0337",   -- LUI x6, 0xDEAD0
    --     3  => x"00000397",   -- AUIPC x7, 0x0

    --     -- I-TYPE
    --     4  => x"00A00293",   -- ADDI x5, x0, 10
    --     5  => x"FFB00313",   -- ADDI x6, x0, -5
    --     6  => x"0142A393",   -- SLTI x7, x5, 20
    --     7  => x"0FF2C513",   -- XORI x10, x5, 0xFF
    --     8  => x"00F56513",   -- ORI x10, x10, 0x00F
    --     9  => x"0F057513",   -- ANDI x10, x10, 0x0F0
    --     10 => x"00800293",   -- ADDI x5, x0, 8
    --     11 => x"00229313",   -- SLLI x6, x5, 2
    --     12 => x"00135393",   -- SRLI x7, x6, 1
    --     13 => x"FF800293",   -- ADDI x5, x0, -8
    --     14 => x"4012D313",   -- SRAI x6, x5, 1
    --     15 => x"00A00293",   -- ADDI x5, x0, 10
    --     16 => x"FFB00313",   -- ADDI x6, x0, -5
    --     17 => x"00A33593",   -- SLTIU x11, x6, 10
    --     18 => x"0142B613",   -- SLTIU x12, x5, 20

    --     -- R-TYPE
    --     19 => x"00F00293",   -- ADDI x5, x0, 15
    --     20 => x"00300313",   -- ADDI x6, x0, 3
    --     21 => x"006283B3",   -- ADD x7, x5, x6
    --     22 => x"40628533",   -- SUB x10, x5, x6
    --     23 => x"006293B3",   -- SLL x7, x5, x6
    --     24 => x"0063D3B3",   -- SRL x7, x7, x6
    --     25 => x"F8800293",   -- ADDI x5, x0, -120
    --     26 => x"4062D3B3",   -- SRA x7, x5, x6
    --     27 => x"00500293",   -- ADDI x5, x0, 5
    --     28 => x"00A00313",   -- ADDI x6, x0, 10
    --     29 => x"0062A3B3",   -- SLT x7, x5, x6
    --     30 => x"006033B3",   -- SLTU x7, x0, x6
    --     31 => x"0062C533",   -- XOR x10, x5, x6
    --     32 => x"0062E533",   -- OR x10, x5, x6
    --     33 => x"0062F533",   -- AND x10, x5, x6

    --     -- LOADS AND STORES
    --     34 => x"10000113",   -- ADDI x2, x0, 256
    --     35 => x"000AB2B7",   -- LUI x5, 0x000AB
    --     36 => x"00512023",   -- SW x5, 0(x2)
    --     37 => x"00012303",   -- LW x6, 0(x2)
    --     38 => x"00510223",   -- SB x5, 4(x2)
    --     39 => x"00410383",   -- LB x7, 4(x2)
    --     40 => x"FFF00293",   -- ADDI x5, x0, -1
    --     41 => x"00510423",   -- SB x5, 8(x2)
    --     42 => x"00810383",   -- LB x7, 8(x2)
    --     43 => x"00814383",   -- LBU x7, 8(x2)
    --     44 => x"00511623",   -- SH x5, 12(x2)
    --     45 => x"00C11383",   -- LH x7, 12(x2)
    --     46 => x"00C15383",   -- LHU x7, 12(x2)

    --     -- BRANCHING
    --     47 => x"00500293",   -- ADDI x5, x0, 5
    --     48 => x"00500313",   -- ADDI x6, x0, 5
    --     49 => x"00628463",   -- BEQ x5, x6, +8
    --     50 => x"00100293",   -- ADDI x5, x0, 1
    --     51 => x"00629463",   -- BNE x5, x6, +8
    --     52 => x"00300293",   -- ADDI x5, x0, 3
    --     53 => x"00700313",   -- ADDI x6, x0, 7
    --     54 => x"0062C463",   -- BLT x5, x6, +8
    --     55 => x"00100293",   -- ADDI x5, x0, 1
    --     56 => x"0062D263",   -- BGE x5, x6, +4
    --     57 => x"FFF00293",  -- ADDI x5, x0, -1
    --     58 => x"00100313",  -- ADDI x6, x0, 1
    --     59 => x"00536463",  -- BLTU x6, x5, +8
    --     60 => x"00200293",  -- ADDI x5, x0, 2
    --     61 => x"0062F463",  -- BGEU x5, x6, +8
    --     62 => x"00200293",  -- ADDI x5, x0, 2
    --     63 => x"0062E263",  -- BLTU x5, x6, +4

    --     -- JUMPS
    --     64 => x"008000EF",   -- JAL x1, +8
    --     65 => x"00100293",   -- ADDI x5, x0, 1
    --     66 => x"02A00293",   -- ADDI x5, x0, 42
    --     67 => x"00008067",   -- JALR x0, x1, 0

    --     68 => x"00000063",   -- BEQ x0, x0, 0
    --     others => x"00000013" -- NOP
    -- );

    constant ROM : rom_t := (
        0  => x"00500093", -- ADDI x1, x0, 5
        1  => x"00A00113", -- ADDI x2, x0, 10
        2  => x"002081B3", -- ADD  x3, x1, x2   forwarding test
        3  => x"00312023", -- SW   x3, 0(x2)
        4  => x"00012203", -- LW   x4, 0(x2)
        5  => x"00420233", -- ADD  x4, x4, x4   stall test
        6  => x"00000293", -- ADDI x5, x0, 0
        7  => x"00000313", -- ADDI x6, x0, 0
        8  => x"00628463", -- BEQ  x5, x6, +8   branch
        9  => x"00100393", -- ADDI x7, x0, 1    should be flushed
        10 => x"00200413", -- ADDI x8, x0, 2
        11 => x"00000063", -- BEQ x0, x0, 0
        others => x"00000013"
    );

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                instr <= ROM(to_integer(unsigned(addr(8 downto 2))));
            end if;
        end if;
    end process;

end Behavioral;
