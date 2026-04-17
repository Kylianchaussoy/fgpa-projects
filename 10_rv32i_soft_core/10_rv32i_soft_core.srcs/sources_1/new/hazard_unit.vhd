-- If the instruction in the EX stage is a Memory Read (Load), and its
-- destination register matches either of the source registers of the 
-- instruction currently in the ID stage, we must stall the pipeline for 1 cycle.

library ieee;
use ieee.std_logic_1164.all;

entity hazard_unit is
    Port (
        id_ex_mem_read : in std_logic;
        id_ex_rd_addr : in std_logic_vector(4 downto 0);

        if_id_rs1_addr : in std_logic_vector(4 downto 0);
        if_id_rs2_addr : in std_logic_vector(4 downto 0);

        stall : out std_logic
    );
end entity hazard_unit;

architecture rtl of hazard_unit is
begin
    process(id_ex_mem_read, id_ex_rd_addr, if_id_rs1_addr, if_id_rs2_addr)
    begin
        stall <= '0';

        if (id_ex_mem_read = '1') and (id_ex_rd_addr /= "00000") then
            if (id_ex_rd_addr = if_id_rs1_addr) or (id_ex_rd_addr = if_id_rs2_addr) then
                stall <= '1';
            end if;
        end if;

    end process;
end architecture rtl;
