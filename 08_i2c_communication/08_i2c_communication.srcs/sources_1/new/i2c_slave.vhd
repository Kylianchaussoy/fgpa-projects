library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity i2c_slave is
Generic (
    SLAVE_ADDRESS : std_logic_vector := "0000001"
);
Port (
    clk : in std_logic;
    rst : in std_logic;
    clock_stretching_en : in std_logic;
    
    -- I2C pins
    sda_in : in std_logic;
    sda_out : out std_logic;
    sda_en : out std_logic;
    scl_in : in std_logic;
    scl_out : out std_logic
);
end i2c_slave;

architecture Behavioral of i2c_slave is
type t_state is ( IDLE, 
                  READ_ADDRESS, SEND_ADDR_ACK, 
                  READ_DATA, SEND_DATA_ACK,
                  WRITE_DATA, READ_DATA_ACK, 
                  WAIT_RISING_EDGE );
                 
signal state : t_state := IDLE;
signal state_after_wait : t_state := IDLE;

signal scl_prev : std_logic := '0';
signal sda_prev : std_logic := '0';

signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
signal addr_reg : std_logic_vector(7 downto 0) := (others => '0');
signal bit_count : natural range 0 to 7 := 0;

constant DATA_TO_SEND : std_logic_vector(7 downto 0) := "11010011"; -- random data
constant NACK_TEST_BYTE : std_logic_vector(7 downto 0) := "10011001"; -- random data
 
begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            sda_en <= '0';
            scl_out <= '1';
            state <= IDLE;
            state_after_wait <= IDLE;
            scl_prev <= '0';
            sda_prev <= '0';
            data_reg <= (others => '0');
            addr_reg <= (others => '0');
            bit_count <= 0;
        else
            scl_prev <= scl_in;
            sda_prev <= sda_in;
            
            if clock_stretching_en = '1' then
                if scl_in = '0' then
                    scl_out <= '0';
                end if;
            else
                scl_out <= '1';
            end if;
            
            -- detect start/restart condition
            if (sda_prev = '1' and sda_in = '0' and scl_in = '1') then
                state <= READ_ADDRESS;
                bit_count <= 0;
                data_reg <= DATA_TO_SEND;
                
            -- detect stop condition
            elsif (sda_prev = '0' and sda_in = '1' and scl_in = '1') then
                state <= IDLE;
            else
                case state is
                
                when IDLE =>
                    sda_en <= '0';
                    
                when READ_ADDRESS =>
                    if (scl_prev = '0' and scl_in = '1') then
                        addr_reg <= addr_reg(6 downto 0) & sda_in;
                        if bit_count = 7 then
                            state <= SEND_ADDR_ACK;
                            bit_count <= 0;
                        else
                            bit_count <= bit_count + 1;
                        end if;
                    end if;
                    
                    if (scl_prev = '1' and scl_in = '0') then
                        sda_en <= '0';
                    end if;
                    
                when SEND_ADDR_ACK  =>
                    if addr_reg(7 downto 1) = SLAVE_ADDRESS then
                        if (scl_prev = '1' and scl_in = '0') then
                            sda_en <= '1';
                            sda_out <= '0';
                            if addr_reg(0) = '0' then
                                state <= WAIT_RISING_EDGE;
                                state_after_wait <= READ_DATA;
                            else
                                state <= WRITE_DATA;
                            end if;
                        end if;
                    else
                        state <= IDLE;
                    end if;
                
                when READ_DATA  =>
                    if (scl_prev = '0' and scl_in = '1') then
                        data_reg <= data_reg(6 downto 0) & sda_in;
                        if bit_count = 7 then
                            state <= SEND_DATA_ACK;
                            bit_count <= 0;
                        else
                            bit_count <= bit_count + 1;
                        end if;
                    end if;
                    
                    if (scl_prev = '1' and scl_in = '0') then
                        sda_en <= '0';
                    end if;
                
                when SEND_DATA_ACK =>
                    if (scl_prev = '1' and scl_in = '0') then
                        sda_en <= '1';
                        if data_reg = NACK_TEST_BYTE then -- to test nack
                            sda_out <= '1';
                            state <= IDLE;
                        else
                            sda_out <= '0';
                            state <= WAIT_RISING_EDGE;
                            state_after_wait <= READ_DATA;
                        end if;
                    end if;
                    
                when WRITE_DATA  =>
                    if (scl_prev = '1' and scl_in = '0') then
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
                    if (scl_prev = '0' and scl_in = '1') then
                        if sda_in = '1' then
                            state <= IDLE;
                        else
                            state <= WRITE_DATA;
                            data_reg <= DATA_TO_SEND;
                        end if;
                    end if;
                    
                    if (scl_prev = '1' and scl_in = '0') then
                        sda_en <= '0';
                    end if;
                    
                when WAIT_RISING_EDGE =>
                    if (scl_prev = '0' and scl_in = '1') then
                        state <= state_after_wait;
                    end if;
                    
                when others =>
                    state <= IDLE;
                end case;
            end if;
        end if;
    end if;
end process;

end Behavioral;
