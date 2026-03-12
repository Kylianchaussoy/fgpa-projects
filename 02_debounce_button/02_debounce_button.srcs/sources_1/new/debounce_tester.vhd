----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.03.2026 19:10:31
-- Design Name: 
-- Module Name: debounce_tester - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce_tester is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    button : in std_logic;
    switch_debounce : in std_logic;
    led : out std_logic_vector(15 downto 0)
  );
end debounce_tester;
 
architecture Behavioral of debounce_tester is
    component debounce_button is
        Port (
            clk : in  std_logic;
            rst : in std_logic;
            button_in : in  std_logic;
            button_out : out std_logic
        );
    end component;
 
    constant c_2POW16 : natural := 65536;
    signal s_no_debounce_cpt : natural range 0 to c_2POW16 - 1 := 0;
    signal s_debounce_cpt : natural range 0 to c_2POW16 - 1 := 0;
 
    -- Signal coming out of the debouncer
    signal s_clean_pulse : std_logic;
 
    -- Signals to safely catch the raw bouncing button
    signal s_btn_sync1 : std_logic := '0';
    signal s_btn_sync2 : std_logic := '0';
    signal s_btn_last : std_logic := '0';
 
begin
    inst_debouncer : debounce_button
    port map (
        clk => clk,
        rst => rst,
        button_in => button,
        button_out => s_clean_pulse
    );
 
    p_counters : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_debounce_cpt    <= 0;
                s_no_debounce_cpt <= 0;
                s_btn_sync1       <= '0';
                s_btn_sync2       <= '0';
                s_btn_last        <= '0';
 
            else
                -- clean counter
                if s_clean_pulse = '1' then
                    if s_debounce_cpt < c_2POW16 - 1 then
                        s_debounce_cpt <= s_debounce_cpt + 1;
                    else 
                        s_debounce_cpt <= 0;
                    end if;
                end if;
     
                -- avoid metastability
                s_btn_sync1 <= button;
                s_btn_sync2 <= s_btn_sync1;
                s_btn_last  <= s_btn_sync2;
     
                -- raw counter
                if s_btn_sync2 = '1' and s_btn_last = '0' then
                    if s_no_debounce_cpt < c_2POW16 - 1 then
                        s_no_debounce_cpt <= s_no_debounce_cpt + 1;
                    else 
                        s_no_debounce_cpt <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process p_counters;
    
    p_switch : process (clk) is
    begin
        if rising_edge(clk) then
            if switch_debounce = '1' then
                led <= std_logic_vector(to_unsigned(s_debounce_cpt, 16));
            else
                led <= std_logic_vector(to_unsigned(s_no_debounce_cpt, 16));
            end if;
        end if;
    end process p_switch;
 
end Behavioral;
 
