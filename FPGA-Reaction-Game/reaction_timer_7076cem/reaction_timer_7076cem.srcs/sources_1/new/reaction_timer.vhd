library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reaction_timer is
  Port ( 
        clk, clear : in STD_LOGIC;
        start : in STD_LOGIC;
        done : in STD_LOGIC;
        clear_sig, stop_sig   : out STD_LOGIC;
       count_val : out STD_LOGIC_VECTOR(3 DOWNTO 0);
        en, rng_start  : out STD_LOGIC;
        LED        : out STD_LOGIC);
end reaction_timer;

architecture rtl of reaction_timer is
   TYPE STATE_TYPE IS (idle, rng_s, start_s, s3);--, invalid);
   SIGNAL state   : STATE_TYPE := idle;
signal counter : integer range 2 to 15 := 0;
begin

process (clk, clear, start)
begin
    if (rising_edge(clk)) then
        if (clear = '1') then
            clear_sig <= '1';
            state <= idle;
        else
            case (state) is
                when idle =>
                    LED <= '0';
                    if (start = '1') then
                        clear_sig <= '0';
                        count_val <= "0101";--std_logic_vector(to_unsigned(counter, count_val'length));
                        rng_start <= '1';
                        state <= rng_s;
                    end if;
                when rng_s =>
                    -- ssd needs to turn off either here or previous state

                    if (done = '1') then
                        rng_start <= '0';
                        state <= start_s;
                    end if;
                when start_s =>
                    en <= '1';
                    state <= s3;
                    -- Turn seven segment display LED off???
                    -- wait between 2 to 15 seconds then move to the next state
                    -- get a random number, feed it into another module to count to
                    -- when value is reached, singal to start the next state
                    
                      -- Do the LFSR for the peusudo random number. As the number needs to be between 2-15
                      -- have four bits, and only take into account the three most signiicant bit
                      -- 000X NOTE: THIS DOESN'T WORK, AS THE NUMBER 15 WON'T BE USED
                      -- Instead create a 1Hz/1 second clock that is always running from 2 to 15
                      -- when ever the start button is pressd the take the value in the counter
--                    if (rng = '0' AND stop = '1') then
--                        state <= invalid;
--                    end if;
                    
--                    if (rng = '1') then
--                        state <= s3;
--                    end if;
                when s3 =>
                    en <= '0';
                    state <= idle;
                    -- Start the millisecond counter and display it on the seven segment display
                    
                    -- if counter is 1000 stop the timer and display "1000"
--                when invalid =>
--                    --display 9999 on the seven segment display
--                   LED <= '1';
--                    en <= '0';
            end case;
        end if;
    end if;
end process;

process (clk, clear)
begin
    if (clear = '1') then
            counter <= 2;
    elsif (rising_edge(clk)) then
          counter <= counter + 1;
    end if;
end process;

end rtl;
