library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_master is
Generic (
    CLK_DIV : natural := 500; -- 100kHz
    SLAVE_ADDRESS : std_logic_vector := "0000001"
  );
Port (
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0);
    start_read : in std_logic;
    start_write : in std_logic;
    busy : out std_logic;
    is_burst : in std_logic;
    
    -- I2C pins
    sda_in : in std_logic;
    sda_out : out std_logic;
    sda_en : out std_logic;
    scl_in : in std_logic;
    scl_out : out std_logic
);
end i2c_master;

architecture Behavioral of i2c_master is
type t_state is (IDLE, 
                 SEND_START, SEND_STOP_1, SEND_STOP_2, 
                 SEND_ADDRESS, RECEIVE_ADDR_ACK, 
                 READ_DATA, SEND_DATA_ACK,
                 WRITE_DATA, READ_DATA_ACK,
                 WAIT_RISING_EDGE);

signal state : t_state := IDLE;
signal state_after_wait : t_state := IDLE;

signal s_scl : std_logic := '1';
signal scl_rising : std_logic := '0';
signal scl_falling : std_logic := '0';

signal clk_counter : natural range 0 to CLK_DIV - 1 := 0;

signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
signal addr_reg : std_logic_vector(7 downto 0) := SLAVE_ADDRESS & '0';
signal bit_count : natural range 0 to 7 := 0;
signal is_read : std_logic := '0';
signal is_clock_stretching : std_logic := '0';

begin

scl_out <= s_scl;

scl_gen : process(clk)
begin
    if rising_edge(clk) then
        scl_rising  <= '0';
        scl_falling <= '0';
        
        if rst = '1' or state = IDLE then
            clk_counter <= 0;
            s_scl <= '1';
        else
            if is_clock_stretching = '1' then
                if scl_in = '1' then
                    is_clock_stretching <= '0';
                    scl_rising  <= '1';
                end if;
            elsif clk_counter = CLK_DIV - 1 then
                clk_counter <= 0;
                s_scl <= not s_scl;
     
                if s_scl = '0' then
                    scl_rising  <= '1';
                    if scl_in = '0' then
                        is_clock_stretching <= '1';
                        scl_rising  <= '0';
                    end if;
                else
                    scl_falling <= '1';
                end if;
            else
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            state <= IDLE;
        else
            case state is
            
            when IDLE =>
                if start_read = '1' or start_write = '1' then
                    state <= SEND_START;
                    sda_en <= '1';
                    sda_out <= '1';
                    busy <= '1';
                 
                    if start_read = '1' then
                        is_read  <= '1';
                        addr_reg <= SLAVE_ADDRESS & '1';
                    else
                        is_read  <= '0';
                        addr_reg <= SLAVE_ADDRESS & '0';
                        data_reg <= data_in;
                    end if;
                else
                    sda_en <= '0';
                    busy   <= '0';
                end if;
                
            when SEND_START =>
                sda_out <= '0';
                if scl_falling = '1' then
                    state <= SEND_ADDRESS;
                    sda_out <= addr_reg(7);
                end if;
                
            when SEND_STOP_1 =>
                if scl_falling = '1' then
                    sda_en <= '1';
                    sda_out <= '0';
                    state <= SEND_STOP_2;
                end if;
                
             when SEND_STOP_2 =>
                if scl_rising = '1' then
                    sda_out <= '1';
                    state <= IDLE;
                end if;        
                
            when SEND_ADDRESS =>
                if scl_falling = '1' then
                    sda_out <= addr_reg(6);
                    addr_reg <= addr_reg(6 downto 0) & '0';
                    
                    if bit_count = 6 then
                        bit_count <= 0;
                        state <= WAIT_RISING_EDGE;
                        state_after_wait <= RECEIVE_ADDR_ACK;
                    else
                        bit_count <= bit_count + 1;
                    end if;
                end if;
                
            when RECEIVE_ADDR_ACK  =>
                if scl_rising = '1' then
                    if sda_in = '0' then
                        if is_read = '0' then
                            state <= WRITE_DATA;
                        else
                            state <= READ_DATA;
                        end if;
                    else
                        state <= SEND_STOP_1;
                    end if;
                end if;
                
                if scl_falling = '1' then
                    sda_en <= '0';
                end if;
                
            when READ_DATA  =>
                if scl_rising = '1' then
                    data_reg <= data_reg(6 downto 0) & sda_in;
                    
                    if bit_count = 7 then
                        state <= SEND_DATA_ACK;
                        bit_count <= 0;
                    else
                        bit_count <= bit_count + 1;
                    end if;
                end if;
                
                if scl_falling = '1' then
                    sda_en <= '0';
                end if;
                
            when SEND_DATA_ACK =>
                data_out <= data_reg;
                if scl_falling = '1' then
                    sda_en <= '1';
                    if is_burst = '1' then
                        sda_out <= '0';
                        state <= WAIT_RISING_EDGE;
                        state_after_wait <= READ_DATA;
                    else
                        sda_out <= '1';
                        state <= SEND_STOP_1;
                    end if;
                end if;
                
            when WRITE_DATA  =>
                if scl_falling = '1' then
                    sda_en <= '1';
                    sda_out <= data_reg(7);
                    data_reg <= data_reg(6 downto 0) & '0';
                    
                    if bit_count = 7 then
                        bit_count <= 0;
                        state <= WAIT_RISING_EDGE;
                        state_after_wait <= READ_DATA_ACK;
                    else
                        bit_count <= bit_count + 1;
                    end if;
                end if;
                
            when READ_DATA_ACK =>
                if scl_rising = '1' then
                    if sda_in = '1' then
                        state <= SEND_STOP_1;
                    else
                        if is_burst = '1' then
                            data_reg <= data_in;
                            state <= WRITE_DATA;
                        else
                            state <= SEND_STOP_1;
                        end if;
                    end if;
                end if;
                
                if scl_falling = '1' then
                    sda_en <= '0';
                end if;
                
            when WAIT_RISING_EDGE =>
                if scl_rising = '1' then
                    state <= state_after_wait;
                end if;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
            when others =>
                state <= SEND_STOP_1;
            end case;
        end if;
    end if;
end process;

end Behavioral;
