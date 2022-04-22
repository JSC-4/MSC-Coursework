library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mbit_counter is
    Generic (N : integer);
    Port ( clk : in STD_LOGIC;
           clear, clear_sig, stop : in STD_LOGIC;
           stop_sig, en : in STD_LOGIC;
           count_out : out STD_LOGIC_VECTOR (N downto 0));
end mbit_counter;

architecture rtl of mbit_counter is
   TYPE STATE_TYPE IS (idle, count_s, stop_1, invalid, reacted);
   SIGNAL state   : STATE_TYPE := idle;
    signal counter : UNSIGNED(N downto 0);
begin

process (clk, clear, stop, clear_sig)
begin
    if (rising_edge(clk)) then
        if (clear = '1') OR (clear_sig = '1') then
            counter <= (others => '0');
            state <= idle;
        else
            case (state) is
                when idle => 
                    if (en = '1') then
                        counter <= (others => '0');
                        state <= count_s;
                    end if;
                when count_s =>
                    counter <= counter + 1;
                    
                    if (stop = '1') then
                        state <= reacted;
                    end if;
                    
                    if (counter > 999) then
                        state <= stop_1;                
                    end if;
                    
                    if (stop_sig = '1') then
                        state <= invalid;
                    end if;               
                when stop_1 =>
                    counter <= "1111101000";
                    state <= idle;
                when invalid =>
--                    counter <= X"270F"; -- display 9999
                when reacted =>
                    state <= idle;
            end case;                   
     end if;
 end if;
 end process;

        -- add code to stop the counter when it gets to 1000
        -- change code to a state machine. Wait until enable signal to switch to counter state. 
        -- If counter reaches to 1000 go to an idle state, otherwise keep counting
        -- Get another signal to say stop button was pressed to early and set counter to 9999



count_out <= std_logic_vector(counter);

end rtl;
