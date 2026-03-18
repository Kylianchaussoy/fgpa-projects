----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 14:31:40
-- Design Name: 
-- Module Name: spi_slave - Behavioral
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

entity spi_slave is
  Port (
    clk : in std_logic;
    rst : in  std_logic;

    -- SPI Pins
    sclk : in std_logic;
    mosi : in std_logic;
    ss : in std_logic;
    miso : out std_logic
  );
end spi_slave;

architecture Behavioral of spi_slave is

signal s_sclk_prev : std_logic := '0';
signal s_tx_shift : std_logic_vector(7 downto 0);
signal s_rx_shift : std_logic_vector(7 downto 0);

signal data_out : std_logic_vector(7 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_tx_shift  <= (others => '0');
                s_rx_shift  <= (others => '0');
                s_sclk_prev <= '0';
            else
                s_sclk_prev <= sclk;
 
                if ss = '1' then
                    s_tx_shift <= data_out; -- loopback
                else
                    -- RISING EDGE
                    if s_sclk_prev = '0' and sclk  = '1' then
                        s_rx_shift <= s_rx_shift(6 downto 0) & mosi;
                    end if;
 
                    -- FALLING EDGE
                    if s_sclk_prev = '1' and sclk = '0' then
                        s_tx_shift <= s_tx_shift(6 downto 0) & '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    miso <= s_tx_shift(7) when ss ='0' else '0';
    data_out <= s_rx_shift;

end Behavioral;
