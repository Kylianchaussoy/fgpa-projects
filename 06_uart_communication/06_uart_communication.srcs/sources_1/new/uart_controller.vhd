----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2026 15:49:54
-- Design Name: 
-- Module Name: uart_controller - Structural
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

entity uart_controller is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    tx_enable : in std_logic;
    
    data_in : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0);
    
    rx : in std_logic;
    tx : out std_logic
  );
end uart_controller;

architecture Structural of uart_controller is
    signal s_tx_start : std_logic;
    
begin
    button_debouncer : entity work.debounce_button
        port map(
            clk => clk,
            rst => rst,
            button_in => tx_enable,
            button_out => s_tx_start
        );
 
    transmitter : entity work.uart_tx
        port map(
            clk => clk,
            rst => rst,
            tx_start => s_tx_start,
            tx_data_in => data_in,
            tx_data_out => tx
        );
 
    receiver : entity work.uart_rx
        port map(
            clk => clk,
            rst => rst,
            rx_data_in => rx,
            rx_data_out => data_out
        );

end Structural;
