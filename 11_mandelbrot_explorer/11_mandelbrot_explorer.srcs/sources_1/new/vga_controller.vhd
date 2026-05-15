library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port (
        clk_25 : in std_logic;
        rst : in  std_logic;
        h_sync : out std_logic;
        v_sync : out std_logic;
        video_on : out std_logic;
        pixel_x : out unsigned(9 downto 0);
        pixel_y : out unsigned(9 downto 0)
    );
end vga_controller;

architecture Behavioral of vga_controller is
    -- VGA 640x480 60Hz Timings
    constant H_DISPLAY : integer := 640;
    constant H_FRONT : integer := 16;
    constant H_SYNC_WIDTH : integer := 96;
    constant H_BACK : integer := 48;
    constant H_TOTAL : integer := H_DISPLAY + H_FRONT + H_SYNC_WIDTH + H_BACK;

    constant V_DISPLAY : integer := 480;
    constant V_FRONT : integer := 10;
    constant V_SYNC_WIDTH : integer := 2;
    constant V_BACK : integer := 33;
    constant V_TOTAL : integer := V_DISPLAY + V_FRONT + V_SYNC_WIDTH + V_BACK;

    signal h_count : unsigned(9 downto 0) := (others => '0');
    signal v_count : unsigned(9 downto 0) := (others => '0');
begin

    process(clk_25, rst)
    begin
        if rst = '1' then
            h_count <= (others => '0');
            v_count <= (others => '0');

        elsif rising_edge(clk_25) then
            if h_count = H_TOTAL - 1 then
                h_count <= (others => '0');
                if v_count = V_TOTAL - 1 then
                    v_count <= (others => '0');
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    h_sync <= '0' when (h_count >= (H_DISPLAY + H_FRONT) and h_count < (H_DISPLAY + H_FRONT + H_SYNC_WIDTH)) else '1';
    v_sync <= '0' when (v_count >= (V_DISPLAY + V_FRONT) and v_count < (V_DISPLAY + V_FRONT + V_SYNC_WIDTH)) else '1';

    video_on <= '1' when (h_count < H_DISPLAY and v_count < V_DISPLAY) else '0';

    pixel_x <= h_count;
    pixel_y <= v_count;

end Behavioral;
