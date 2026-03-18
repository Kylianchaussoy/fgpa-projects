----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 14:31:40
-- Design Name: 
-- Module Name: spi_master - Behavioral
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

entity spi_master is
  Generic (
    CLK_DIV : natural := 50 -- 1MHz
  );
  Port (
    clk : in std_logic;
    rst : in std_logic;
    busy : out std_logic;
    start_tx : in std_logic;
    tx_data : in std_logic_vector(7 downto 0);
    rx_data : out std_logic_vector(7 downto 0);
    
    -- SPI pins
    sclk : out std_logic;
    ss : out std_logic;
    mosi : out std_logic;
    miso : in std_logic
  );
end spi_master;

architecture Behavioral of spi_master is
type t_state is (IDLE, TRANSFER, DONE);
signal s_state : t_state := IDLE;
    
signal s_tx_shift : std_logic_vector(7 downto 0) := (others => '0');
signal s_rx_shift : std_logic_vector(7 downto 0) := (others => '0');

signal s_clk_counter  : natural range 0 to CLK_DIV - 1 := 0;

signal s_sclk     : std_logic := '0';
signal s_sclk_rising  : std_logic := '0';
signal s_sclk_falling : std_logic := '0';
    
signal s_bit_count : natural range 0 to 7 := 0;

begin

p_sclk_gen : process(clk) is
begin
if rising_edge(clk) then
    s_sclk_rising  <= '0';
    s_sclk_falling <= '0';

    if rst = '1' or s_state = IDLE then
        s_clk_counter <= 0;
        s_sclk <= '0';
    else
        if s_clk_counter = CLK_DIV - 1 then
            s_clk_counter <= 0;
            s_sclk <= not s_sclk;
 
            if s_sclk = '0' then
                s_sclk_rising  <= '1';
            else
                s_sclk_falling <= '1';
            end if;
        else
            s_clk_counter <= s_clk_counter + 1;
        end if;
    end if;
end if;
end process p_sclk_gen;

p_fsm : process(clk) is
begin
if rising_edge(clk) then
    if rst = '1' then
        s_state <= IDLE;
        s_tx_shift <= (others => '0');
        s_rx_shift <= (others => '0');
        s_bit_count <= 0;
        busy <= '0';
        ss <= '1';
        mosi <= '0';
    else
        case s_state is
        when IDLE =>
            ss <= '1';
            mosi <= '0';
            busy <= '0';
 
            if start_tx = '1' then
                s_tx_shift  <= tx_data;
                s_bit_count <= 0;
                busy <= '1';
                ss <= '0';
                s_state <= TRANSFER;
 
                -- put msb in mosi before first sclk rising edge
                mosi <= tx_data(7);
            end if;

        when TRANSFER =>
            if s_sclk_rising = '1' then
                s_rx_shift <= s_rx_shift(6 downto 0) & miso;
 
                if s_bit_count = 7 then
                    s_state <= DONE;
                else
                    s_bit_count <= s_bit_count + 1;
                end if;
            end if;

            if s_sclk_falling = '1' then
                mosi <= s_tx_shift(6); -- msb-1
                s_tx_shift <= s_tx_shift(6 downto 0) & '0';
            end if;

        when DONE =>
            ss <= '1';
            mosi <= '0';
            busy <= '0';
            rx_data <= s_rx_shift;
            s_state <= IDLE;

        when others =>
            s_state <= IDLE;
        end case;
    end if;
end if;
end process p_fsm;

-- sclk active only during transfer
sclk <= s_sclk when (s_state = TRANSFER) else '0';

end Behavioral;
