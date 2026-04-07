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

    type rom_type is array(0 to 255) of std_logic_vector(15 downto 0);
    constant instr_mem : rom_type := (
        -- LDI R1, 5  (R1 = 5)
        0 => "0110" & "01" & "00" & "00000101",
        -- LDI R2, 3  (R2 = 3)
        1 => "0110" & "10" & "00" & "00000011",
        -- ADD R3, R1, R2 (R3 = 5 + 3 = 8)
        2 => "0000" & "11" & "01" & "00" & "10" & "0000",
        -- AND R2, R1, R3 (R2 = 5 & 8 = 0)
        3 => "0010" & "10" & "01" & "00" & "11" & "0000",
        -- OR R2, R1, R3  (R2 = 5 | 8 = 13) -> TESTING OR
        4 => "0011" & "10" & "01" & "00" & "11" & "0000",
        -- LDI R1, 13 (R1 = 13)
        5 => "0110" & "01" & "00" & "00001101",
        -- BEQ R1, R2, 9 (If 13 == 13, Jump to 9)
        6 => "1001" & "01" & "10" & "00001001",
        -- LDI R3, 255 (This should be skipped by the BEQ above)
        7 => "0110" & "11" & "00" & "11111111",
        -- JMP 12 (This should be skipped by the BEQ above)
        8 => "1000" & "00" & "00" & "00001100",
        -- XOR R1, R1, R2 (R1 = 13 ^ 13 = 0)
        9 => "0100" & "01" & "01" & "00" & "10" & "0000",
        -- BEQ R1, R3, 7 (If 0 == 8, Jump to 7)
        10 => "1001" & "01" & "11" & "00000111",
        -- JMP 13
        11 => "1000" & "00" & "00" & "00001101",
        -- LDI R1, 170 (This should be skipped by the JMP above)
        12 => "0110" & "01" & "00" & "10101010",
        -- MOV R3, R2 (R3 = 13)
        13 => "0111" & "11" & "10" & "00000000",
        -- HLT
        14 => "1111" & "00" & "00" & "00000000",
        others => (others => '0')
    );

end package simple_cpu_pkg;
