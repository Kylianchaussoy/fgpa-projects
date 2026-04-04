library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_controller is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0);
    is_burst : in std_logic;
    clock_stretching : in std_logic;
    start_read : in std_logic;
    start_write : in std_logic;
    busy : out std_logic
  );
end i2c_controller;

architecture Structural of i2c_controller is
signal s_start_read : std_logic;
signal s_start_write : std_logic;
signal master_sda_out : std_logic;
signal master_sda_en : std_logic;
signal master_sda_in : std_logic;
signal slave_sda_out : std_logic;
signal slave_sda_en : std_logic;
signal slave_sda_in : std_logic;
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
    
    master : entity work.i2c_master
        port map(
            clk => clk,
            rst => rst,
            data_in => data_in,
            data_out => data_out,
            start_read => s_start_read,
            start_write => s_start_write,
            busy => busy,
            is_burst => is_burst,
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
            clock_stretching => clock_stretching,
            sda_in => slave_sda_in,
            sda_out => slave_sda_out,
            sda_en => slave_sda_en,
            scl_in => slave_scl_in,
            scl_out => slave_scl_out
        );
    
    start_write_debounce : entity work.debounce_button
        port map(
            clk => clk,
            rst => rst,
            button_in => start_write,
            button_out => s_start_write
        );
        
    start_read_debounce : entity work.debounce_button
        port map(
            clk => clk,
            rst => rst,
            button_in => start_read,
            button_out => s_start_read
        );

end Structural;
