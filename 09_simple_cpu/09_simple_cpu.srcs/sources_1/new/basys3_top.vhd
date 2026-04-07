library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity basys3_top is
    Port (
        clk : in std_logic;
        rst : in std_logic;
        led : out std_logic_vector(15 downto 0);
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0);
        dp : out std_logic
    );
end entity;

architecture Structural of basys3_top is
    signal slow_clk : std_logic;
    signal halt : std_logic;
    signal dbg_pc : std_logic_vector(7 downto 0);
    signal dbg_r1 : std_logic_vector(7 downto 0);
    signal dbg_r2 : std_logic_vector(7 downto 0);
    signal dbg_alu : std_logic_vector(7 downto 0);
    signal seven_seg : std_logic_vector(15 downto 0) := (others => '0');

begin

    dp <= not halt;
    led(15 downto 8) <= dbg_r1;
    led(7 downto 0) <= dbg_r2;
    seven_seg <= dbg_pc & dbg_alu;

    clk_divider_inst: entity work.clk_divider
        port map (
            clk_in => clk,
            rst => rst,
            clk_out => slow_clk
        );

    cpu_top_inst: entity work.cpu_top
        port map (
            clk => slow_clk,
            rst => rst,
            dbg_pc => dbg_pc,
            dbg_r1 => dbg_r1,
            dbg_r2 => dbg_r2,
            dbg_alu => dbg_alu,
            halted => halt
        );

    seven_seg_inst: entity work.seven_seg
        port map (
            clk => clk,
            data_in => seven_seg,
            seg => seg,
            an => an
        );

end architecture;
