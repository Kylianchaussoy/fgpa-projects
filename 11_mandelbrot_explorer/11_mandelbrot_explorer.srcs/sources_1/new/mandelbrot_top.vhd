library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mandelbrot_top is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        btnL : in std_logic;
        btnR : in std_logic;
        btnD : in std_logic;
        btnU : in std_logic;
        btnC : in std_logic;
        sw : in std_logic;
        vga_hs : out std_logic;
        vga_vs : out std_logic;
        vga_r : out std_logic_vector(3 downto 0);
        vga_g : out std_logic_vector(3 downto 0);
        vga_b : out std_logic_vector(3 downto 0)
    );
end mandelbrot_top;

architecture Behavioral of mandelbrot_top is
    
    component clk_wiz_0 is
        Port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic
        );
    end component;

    signal pixel_clk : std_logic;
    
    signal video_on : std_logic;
    signal pixel_x : unsigned(9 downto 0);
    signal pixel_y : unsigned(9 downto 0);

    signal latched_x : unsigned(9 downto 0);
    signal latched_y : unsigned(9 downto 0);

    signal c_re : signed(27 downto 0);
    signal c_im : signed(27 downto 0);

    signal mb_start : std_logic := '0';
    signal mb_done : std_logic;
    
    signal mb_iter : unsigned(6 downto 0);

    signal result_iter : unsigned(6 downto 0) := (others => '0');
    signal result_done : std_logic := '0';

    signal write_addr : unsigned(18 downto 0);
    signal read_addr : unsigned(18 downto 0);
    signal bram_we : std_logic := '0';
    signal bram_data_out : unsigned(3 downto 0);

    signal compute_x : unsigned(9 downto 0) := (others => '0');
    signal compute_y : unsigned(9 downto 0) := (others => '0');

    type state_type is (
        IDLE,
        COMPUTING,
        OUTPUT
    );
    signal state : state_type := IDLE;

    signal prev_x : unsigned(9 downto 0) := (others => '1');
    signal prev_y : unsigned(9 downto 0) := (others => '1');

    signal pixel_color: std_logic_vector(11 downto 0);

    signal zoom : std_logic := '0';
    signal pan_left : std_logic := '0';
    signal pan_right : std_logic := '0';
    signal pan_up : std_logic := '0';
    signal pan_down : std_logic := '0';

begin
    
    clk_wiz_0_inst : clk_wiz_0
        port map (
            clk_in1 => clk, -- 100Mhz
            reset => reset,
            clk_out1 => pixel_clk -- 25 Mhz
        );

    vga_controller_inst : entity work.vga_controller
        port map (
            clk_25 => pixel_clk,
            rst => reset,
            h_sync => vga_hs,
            v_sync => vga_vs,
            video_on => video_on,
            pixel_x => pixel_x,
            pixel_y => pixel_y
        );

    mandelbrot_core_inst : entity work.mandelbrot_core
        port map (
            clk => clk,
            rst => reset,
            start => mb_start,
            c_re => c_re,
            c_im => c_im,
            iter_count => mb_iter,
            done => mb_done
        );

    coordinate_mapper_inst : entity work.coordinate_mapper
        port map (
            clk_25 => pixel_clk,
            pan_right => pan_right,
            pan_left => pan_left,
            pan_down => pan_down,
            pan_up => pan_up,
            zoom => zoom,
            zoom_mode => sw,
            pixel_x => compute_x,
            pixel_y => compute_y,
            scaled_x => c_re,
            scaled_y => c_im
        );
                    
    frame_buffer_inst : entity work.frame_buffer
        port map(
            clk_write => clk,
            we => bram_we,
            addr_write => write_addr,
            data_in => mb_iter(3 downto 0),
            clk_read => pixel_clk,
            addr_read => read_addr,
            data_out => bram_data_out
        );

    color_mapper_inst: entity work.color_mapper
        port map(
            iter_count => bram_data_out, 
            done => '1',
            rgb => pixel_color
        );

    debounce_btnC: entity work.debounce_button 
        port map (
            clk => pixel_clk,
            rst => reset,
            button_in => btnC,
            button_out => zoom
        );
    debounce_btnU: entity work.debounce_button 
        port map (
            clk => pixel_clk,
            rst => reset,
            button_in => btnU,
            button_out => pan_up
        );
    debounce_btnD : entity work.debounce_button 
        port map (
            clk => pixel_clk,
            rst => reset,
            button_in => btnD,
            button_out => pan_down
        );
    debounce_btnL : entity work.debounce_button 
        port map (
            clk => pixel_clk,
            rst => reset,
            button_in => btnL,
            button_out => pan_left
        );
    debounce_btnR : entity work.debounce_button 
        port map (
            clk => pixel_clk,
            rst => reset,
            button_in => btnR,
            button_out => pan_right
        );

    vga_r <= pixel_color(11 downto 8) when (video_on = '1') else "0000";
    vga_g <= pixel_color(7 downto 4)  when (video_on = '1') else "0000";
    vga_b <= pixel_color(3 downto 0)  when (video_on = '1') else "0000";
    
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            mb_start <= '0';
            bram_we <= '0';
            compute_x <= (others => '0');
            compute_y <= (others => '0');

        elsif rising_edge(clk) then
            mb_start <= '0';
            bram_we <= '0';

            if (pixel_x < 640 and pixel_y < 480) then
                read_addr <= to_unsigned(to_integer(pixel_y) * 640 + to_integer(pixel_x), 19);
            else
                read_addr <= (others => '0');
            end if;
            -- read_addr <= to_unsigned(to_integer(pixel_y) * 640 + to_integer(pixel_x), 19) 
            --     when (pixel_x < 640 and pixel_y < 480) else (others => '0');

            if (compute_x < 640 and compute_y < 480) then
                write_addr <= to_unsigned(to_integer(compute_y) * 640 + to_integer(compute_x), 19);
            else
                write_addr <= (others => '0');
            end if;
            -- write_addr <= to_unsigned(to_integer(compute_y) * 640 + to_integer(compute_x), 19) 
            --       when (compute_x < 640 and compute_y < 480) else (others => '0');

            case state is

                when IDLE =>
                    mb_start <= '1';  
                    state <= COMPUTING;

                when COMPUTING =>
                    if mb_done = '1' then
                        bram_we <= '1'; 

                        if compute_x = 639 then
                            compute_x <= (others => '0');
                            if compute_y = 479 then
                                compute_y <= (others => '0');
                            else
                                compute_y <= compute_y + 1;
                            end if;
                        else
                            compute_x <= compute_x + 1;
                        end if;

                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;

            end case;
        end if;
    end process;

end Behavioral;
