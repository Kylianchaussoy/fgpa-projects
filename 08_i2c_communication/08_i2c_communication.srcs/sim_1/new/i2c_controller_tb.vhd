library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_controller_tb is
--  Port ( );
end i2c_controller_tb;

architecture Behavioral of i2c_controller_tb is

constant CLK_PERIOD : time := 10 ns; -- 100Mhz
constant DATA_SUCCESS : std_logic_vector(7 downto 0) := "11010011";

signal clk : std_logic;
signal rst : std_logic;
signal data_in : std_logic_vector(7 downto 0);
signal data_out : std_logic_vector(7 downto 0);
signal burst_en : std_logic;
signal clock_stretching_en : std_logic;
signal start_read : std_logic;
signal start_write : std_logic;
signal busy : std_logic;

begin

clk_process : process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

i2c_controller_inst : entity work.i2c_controller(Structural)
    generic map (
        SIM_DEBOUNCE_COUNTER => 100
    )
    port map(
        clk => clk,
        rst => rst,
        data_in => data_in,
        data_out => data_out,
        burst_en => burst_en,
        clock_stretching_en => clock_stretching_en,
        start_read => start_read,
        start_write => start_write,
        busy => busy
    );
    
process
begin
    -- NOTE: This testbench is for integration sanity checking only.
    -- For exhaustive protocol, NACK, burst, and clock stretching 
    -- testing, please refer to 'i2c_system_tb'.
    
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;
    
    start_write <= '0';
    start_read <= '0';
    burst_en <= '0';
    clock_stretching_en <= '0';
    data_in <= (others => '0');
 
    -- one write
    start_write <= '1';
    wait until busy = '1';
    start_write <= '0';
    wait until busy = '0';
    wait for 200 us;
 
    -- one read
    start_read <= '1';
    wait until busy = '1';
    start_read <= '0';
    wait until busy = '0';
    assert data_out = DATA_SUCCESS severity failure;
 
    report "simulation complete";
    wait;
 
end process;

end Behavioral;
