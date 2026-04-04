library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_system_tb is
--  Port ( );
end i2c_system_tb;

architecture test of i2c_system_tb is

constant CLK_PERIOD : time := 10 ns; -- 100Mhz
constant NACK_BYTE : std_logic_vector(7 downto 0) := "10011001";
constant DATA_SUCCESS : std_logic_vector(7 downto 0) := "11010011";

signal clk : std_logic;
signal rst : std_logic;
signal data_in : std_logic_vector(7 downto 0);
signal data_out : std_logic_vector(7 downto 0);
signal start_read : std_logic;
signal start_write : std_logic;
signal busy : std_logic;
signal burst_en : std_logic;
signal clock_stretching_en : std_logic;

signal master_sda_out: std_logic;
signal master_sda_en: std_logic;
signal master_sda_in: std_logic;
signal slave_sda_out : std_logic;
signal slave_sda_en: std_logic;
signal slave_sda_in: std_logic;
signal sda_bus: std_logic;

signal master_scl_in : std_logic;
signal master_scl_out : std_logic;
signal slave_scl_in : std_logic;
signal slave_scl_out : std_logic;
signal scl_bus : std_logic;

begin

    sda_bus <= '0' when (master_sda_en = '1' and master_sda_out = '0')
                   or (slave_sda_en  = '1' and slave_sda_out  = '0')
                   else '1';
    master_sda_in <= sda_bus;
    slave_sda_in  <= sda_bus;
    
    scl_bus <= '0' when slave_scl_out = '0' 
                   or master_scl_out = '0'
                   else '1';
    master_scl_in <= scl_bus;
    slave_scl_in <= scl_bus;
    
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    master : entity work.i2c_master
        port map(
            clk => clk,
            rst => rst,
            data_in => data_in,
            data_out => data_out,
            start_read => start_read,
            start_write => start_write,
            busy => busy,
            burst_en => burst_en,
            sda_in => master_sda_in,
            sda_out => master_sda_out,
            sda_en => master_sda_en,
            scl_in => master_scl_in,
            scl_out => master_scl_out
        );
        
    slave : entity work.i2c_slave
        port map(
            clk => clk,
            rst => rst,
            clock_stretching_en => clock_stretching_en,
            sda_in => slave_sda_in,
            sda_out => slave_sda_out,
            sda_en => slave_sda_en,
            scl_in => slave_scl_in,
            scl_out => slave_scl_out
        );
    
process
begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;
    burst_en <= '0';
    clock_stretching_en <= '0';

    -- one write
    data_in <= "11110000";
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
    wait for 200 us;

    -- burst write
    data_in <= "10110001";
    burst_en <= '1';
    start_write <= '1';
    wait until busy = '1';
    start_write <= '0';
    wait for 1 ms;
    burst_en <= '0';
    wait until busy = '0';
    wait for 200 us;

    -- burst read
    burst_en <= '1';
    start_read <= '1';
    wait until busy = '1';
    start_read <= '0';
    wait for 1 ms;
    burst_en <= '0';
    wait until busy = '0';
    assert data_out = DATA_SUCCESS severity failure;
    wait for 200 us;

    -- check if slave is reading correct value
    data_in <= "11110000";
    burst_en <= '1';
    start_write <= '1';
    wait until busy = '1';
    start_write <= '0';
    wait for 1 ms;
    data_in <= NACK_BYTE; -- slave should nack when reading this byte
    wait until busy = '0';
    wait for 200 us;

    -- clock stretching when writing
    data_in <= "11110000";
    burst_en <= '1';
    clock_stretching_en <= '0';
    start_write <= '1';
    wait until busy = '1';
    start_write <= '0';
    wait for 1 ms;
    clock_stretching_en <= '1';
    wait for 1 ms;
    clock_stretching_en <= '0';
    wait for 1 ms;
    burst_en <= '0';
    wait until busy = '0';
    wait for 200 us;

    -- clock stretching when reading
    burst_en <= '1';
    clock_stretching_en <= '0';
    start_read <= '1';
    wait until busy = '1';
    start_read <= '0';
    wait for 1 ms;
    clock_stretching_en <= '1';
    wait for 1 ms;
    clock_stretching_en <= '0';
    wait for 1 ms;
    burst_en <= '0';
    wait until busy = '0';
    
    report "simulation complete";
    wait;   
end process;

end test;
