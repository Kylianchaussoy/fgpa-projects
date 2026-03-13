----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2026 16:01:35
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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

entity uart_rx is
generic (
    CLK_FREQ   : integer := 100_000_000;
    BAUD_RATE  : integer := 9_600;
    SAMPLE_RATE : integer := 16
);
  Port (
    clk : in std_logic;
    rst : in std_logic;
    rx_data_in : in std_logic;
    rx_data_out : out std_logic_vector (7 downto 0)
  );
end uart_rx;

architecture Behavioral of uart_rx is

constant c_SAMPLE_DIVIDER : integer := CLK_FREQ / (BAUD_RATE * SAMPLE_RATE);
constant c_SAMPLES_TO_CENTER : integer := (SAMPLE_RATE / 2) - 1;
constant c_SAMPLES_PER_BIT   : integer := SAMPLE_RATE - 1;  

type t_rx_state is (IDLE, START, DATA, STOP);
signal s_state : t_rx_state := IDLE;

signal s_baud_rate_clk : std_logic := '0';
signal s_baud_count : natural range 0 to c_SAMPLE_DIVIDER - 1 := 0;
signal s_sample_count  : natural range 0 to c_SAMPLES_PER_BIT  := 0;

signal s_shift_reg : std_logic_vector(7 downto 0) := (others => '0');
signal s_bit_count : natural range 0 to 7  := 0;

begin

p_baud_rate_generator : process(clk) is
begin
if rising_edge(clk) then
    if rst = '1' then
        s_baud_rate_clk <= '0';
        s_baud_count <= 0;
    else
        if s_baud_count = c_SAMPLE_DIVIDER - 1 then
            s_baud_rate_clk <= '1';
            s_baud_count <= 0;
        else
            s_baud_rate_clk <= '0';
            s_baud_count <= s_baud_count + 1;
        end if;
    end if;
end if;
end process p_baud_rate_generator;

p_rx_fsm : process(clk) is
begin
if rising_edge(clk) then
    if rst = '1' then
        s_state <= IDLE;
        rx_data_out <= (others => '0');
        s_shift_reg <= (others => '0');
        s_sample_count <= 0;
        s_bit_count <= 0;
    else
        if s_baud_rate_clk = '1' then
            case s_state is
            
            when IDLE =>
                s_sample_count <= 0;
                s_bit_count <= 0;
                s_shift_reg <= (others => '0');
                
                if rx_data_in = '0' then
                    s_state <= START;
                end if;   
                         
            when START =>
                if rx_data_in = '0' then
                    if s_sample_count = c_SAMPLES_TO_CENTER then
                        s_sample_count <= 0;
                        s_state <= DATA;
                    else
                        s_sample_count <= s_sample_count + 1;
                    end if;
                else
                    s_state <= IDLE;
                end if;
                
            when DATA =>
                if s_sample_count = c_SAMPLES_PER_BIT then
                    s_shift_reg <= rx_data_in & s_shift_reg(7 downto 1);
                    s_sample_count <= 0;
                    
                    if s_bit_count = 7 then
                        s_state <= STOP;
                    else
                        s_bit_count <= s_bit_count + 1;
                    end if;
                else
                    s_sample_count <= s_sample_count + 1;
                end if;
                
            when STOP =>
                if s_sample_count = c_SAMPLES_PER_BIT then
                    rx_data_out <= s_shift_reg;
                    s_state <= IDLE;
                else
                    s_sample_count <= s_sample_count + 1;
                end if;
                
            when others =>
                s_state <= IDLE;
            end case;
        end if;
    end if;
end if;
end process p_rx_fsm;

end Behavioral;
