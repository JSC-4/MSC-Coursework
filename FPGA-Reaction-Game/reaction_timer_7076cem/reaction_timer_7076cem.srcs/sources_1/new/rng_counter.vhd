library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rng_counter is
    Port ( clk : in STD_LOGIC;
           clear : in STD_LOGIC;
           count_val : in STD_LOGIC_VECTOR(3 DOWNTO 0);
           start_sig : in STD_LOGIC;
           done : out STD_LOGIC);
end rng_counter;

architecture rtl of rng_counter is
   TYPE STATE_TYPE IS (idle, start_s, s3);--, invalid);
   SIGNAL state   : STATE_TYPE := idle;
    signal counter : integer range 2 to 15 := 0;
begin

process (clk, clear, start_sig)
begin
    if (rising_edge(clk)) then
        if (clear = '1') then
            done <= '0';
            state <= idle;
        else
            case (state) is
                when idle =>
                    done <= '0';
                    if (start_sig = '1') then
                        state <= start_s;
                    end if;
                when start_s =>
                    counter <= counter + 1;
                    if (counter = to_integer(unsigned(count_val))) then
                        done <= '1';
                        state <= s3;
                    end if;
                when s3 =>
--                    done <= '0';
                    state <= idle;
            end case;
        end if;
    end if;
end process;

end rtl;
