----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2026 15:49:54
-- Design Name: 
-- Module Name: uart_tx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
generic (
    CLK_FREQ   : integer := 100_000_000;
    BAUD_RATE  : integer := 9_600
);
  Port (
    clk : in std_logic;
    rst : in std_logic;
    tx_start : in  std_logic;
    tx_data_in : in std_logic_vector (7 downto 0);
    tx_data_out : out std_logic
  );
end uart_tx;

architecture Behavioral of uart_tx is
constant c_BAUD_CLK_TICKS : integer := CLK_FREQ / BAUD_RATE;

type t_tx_states is (IDLE, START, DATA, STOP);
signal s_state : t_tx_states := IDLE;

signal s_baud_rate_clk : std_logic := '0';
signal s_baud_count : natural range 0 to c_BAUD_CLK_TICKS -1 := 0;

signal s_start_detected : std_logic := '0';
signal s_clear_start_flag  : std_logic := '0';
signal s_tx_data : std_logic_vector(7 downto 0) := (others=>'0');

signal s_shift_reg : std_logic_vector(7 downto 0) := (others => '0');
signal s_bit_count : natural range 0 to 7 := 0;

begin

p_baud_rate_clk_generator: process(clk) is
begin
    if rising_edge(clk) then
        if rst = '1' then
            s_baud_rate_clk <= '0';
            s_baud_count <= 0;
        else
            if s_baud_count = c_BAUD_CLK_TICKS - 1 then
                s_baud_rate_clk <= '1';
                s_baud_count <= 0;
            else
                s_baud_rate_clk <= '0';
                s_baud_count <= s_baud_count + 1;
            end if;
        end if;
    end if;
end process p_baud_rate_clk_generator;

p_tx_start_detector: process(clk) is
    begin
    if rising_edge(clk) then
        if rst ='1' or s_clear_start_flag = '1' then
            s_start_detected <= '0';
        else
            if tx_start = '1' and s_start_detected = '0' then
                s_start_detected <= '1';
                s_tx_data <= tx_data_in;
            end if;
        end if;
    end if;
end process p_tx_start_detector;

p_tx_fsm: process(clk) is
begin
if rising_edge(clk) then
    if rst = '1' then
        s_state <= IDLE;
        s_clear_start_flag <= '1';
        tx_data_out <= '1';
        s_shift_reg <= (others => '0');
        s_bit_count <= 0;
    else
        if s_baud_rate_clk = '1' then
            case s_state is
            
            when IDLE =>
                s_clear_start_flag <= '0';
                tx_data_out <= '1';
                
                if s_start_detected = '1' then
                    s_state <= START;
                end if;
                
            when START =>
                tx_data_out <= '0';
                s_shift_reg <= s_tx_data;
                s_bit_count <= 0;
                s_state <= DATA;
                
            when DATA =>
                tx_data_out <= s_shift_reg(0);
                s_shift_reg <= '0' & s_shift_reg(7 downto 1);
                
                if s_bit_count  = 7 then
                    s_state <= STOP;
                else
                    s_bit_count <= s_bit_count + 1;
                end if;
                
            when STOP =>
                tx_data_out <= '1';
                s_clear_start_flag <= '1';
                s_state <= IDLE;
                
            when others =>
                s_state <= IDLE;
            end case;
        end if;
    end if;
end if;
end process p_tx_fsm;

end Behavioral;
