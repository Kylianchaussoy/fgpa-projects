----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.03.2026 15:25:37
-- Design Name: 
-- Module Name: spi_controller - Structural
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

entity spi_controller is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    start_tx : in std_logic;
    busy : out std_logic;
    
    tx_data : in std_logic_vector(7 downto 0);
    rx_data : out std_logic_vector(7 downto 0)
  );
end spi_controller;

architecture Structural of spi_controller is
signal s_start_tx : std_logic;
signal s_sclk : std_logic;
signal s_mosi : std_logic;
signal s_miso : std_logic;
signal s_ss   : std_logic;

begin   
    master : entity work.spi_master
        port map(
            clk => clk,
            rst => rst,
            busy => busy,
            start_tx => s_start_tx,
            tx_data => tx_data,
            rx_data => rx_data,
            sclk => s_sclk,
            ss => s_ss,
            mosi => s_mosi,
            miso => s_miso
        );
        
    slave : entity work.spi_slave
        port map(
            clk => clk,
            rst => rst,
            sclk => s_sclk,
            mosi => s_mosi,
            ss => s_ss,
            miso => s_miso
        );
        
    button_debouncer : entity work.debounce_button
        port map(
            clk => clk,
            rst => rst,
            button_in => start_tx,
            button_out => s_start_tx
        );

end Structural;
