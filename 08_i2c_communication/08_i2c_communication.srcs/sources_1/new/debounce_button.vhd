library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce_button is
    generic (
        COUNTER_SIZE : integer := 1_000_000
    );
  
  Port (
    clk : in std_logic;
    rst : in std_logic;
    button_in : in std_logic;
    button_out : out std_logic
  );
end debounce_button;

architecture Behavioral of debounce_button is
    -- protection against metastability
    signal s_sync_ff1 : std_logic := '0';
    signal s_sync_ff2 : std_logic := '0';
    
    signal s_ff1 : std_logic := '0';
    signal s_ff2 : std_logic := '0';
    signal s_ff3 : std_logic := '0';
    signal s_count : natural range 0 to COUNTER_SIZE := 0;
    
begin
    p_debounce_all : process(clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_sync_ff1 <= '0';
                s_sync_ff2 <= '0';
                s_ff1      <= '0';
                s_count    <= 0;
                s_ff2      <= '0';
                s_ff3      <= '0';
            else    
                s_sync_ff1 <= button_in;
                s_sync_ff2 <= s_sync_ff1;
                s_ff1      <= s_sync_ff2;
                
                if (s_ff1 xor s_sync_ff2) = '1' then 
                    s_count <= 0;
                elsif s_count < COUNTER_SIZE then
                    s_count <= s_count + 1;
                else
                    s_ff2 <= s_ff1;
                end if;
                
                s_ff3 <= s_ff2;
            end if;
        end if;
    end process p_debounce_all;
    
    button_out <= s_ff2 and (not s_ff3);
                
end Behavioral;
