library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reaction is
  Port ( 
        clk, clear : in STD_LOGIC;
        start, stop : in STD_LOGIC;
        rng_done, clear_sig : in STD_LOGIC;
        unit, tens : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        hundreds, thousands : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        seg : out  STD_LOGIC_VECTOR (6 downto 0);
        an : out  STD_LOGIC_VECTOR (7 downto 0);
       count_val : out STD_LOGIC_VECTOR(3 DOWNTO 0);
        start_rng, start_counter : out STD_LOGIC;
        LED : out STD_LOGIC);
end reaction;

architecture rtl of reaction is
   TYPE STATE_TYPE IS (idle_s, start_s, react_s, stop_s);--, invalid);
   SIGNAL state   : STATE_TYPE := idle_s;
	SIGNAL digit : STD_LOGIC_VECTOR (3 downto 0);
    SIGNAL s	: UNSIGNED(1 downto 0) := "00";
    signal counter : integer range 2 to 15 := 0;

begin

process (clk, clear, start, stop, rng_done, clear_sig)
begin
    if (rising_edge(clk)) then
        if (clear = '1') then
            state <= idle_s;
            start_rng <= '0';
            start_counter <= '0';
            LED <= '0';
        else
            case (state) is 
                when idle_s => 
                    LED <= '0'; -- turn LED off
                    start_rng <= '0';
                    start_counter <= '0';
                -- Display "HI" on the seven segment display
                 case (s) is
                    when "00" => digit <= (others => '0'); an <= "11111111";
                    when "01" => digit <= (others => '0'); an <= "11111111";
                    when "10" => digit <= X"1"; an <= "11111011";
                    when others => digit <= X"A"; an <= "11110111";
                end case;
                
                if (start = '1') then
                    state <= start_s;
                end if;
                
                when start_s =>
                    -- Turn the seven segment display off
                     case (s) is    
                        when "00" => digit <= (others => '0'); an <= "11111111";
                        when "01" => digit <= (others => '0'); an <= "11111111";
                        when "10" => digit <= X"1"; an <= "11111011";
                        when others => digit <= X"A"; an <= "11110111";
                    end case;
                    
                    -- Start the random number generator 
                    count_val <= std_logic_vector(to_unsigned(counter, count_val'length));
                    start_rng <= '1';
                    
                    -- Wait for signal that random time has finished
                    if (rng_done <= '1') then
                        start_rng <= '0';
                        state <= react_s;
                    else 
                        state <= start_s;
                    end if;
                    
                when react_s =>
                    LED <= '1'; -- Turn LED on
                    
                    -- start the millisecond timer
                    start_counter <= '1';
--                    start_counter <= '0'; -- stop the counter

                    case (s) is
                        when "00" => digit <= unit; an <= "11111110";
                        when "01" => digit <= tens; an <= "11111101";
                        when "10" => digit <= hundreds; an <= "11111011";
                        when others => digit <= thousands; an <= "11110111";
                    end case;
                    
                    if (stop = '1') then
                        start_counter <= '0'; -- stop the counter
                        state <= stop_s;
                    end if;
                    if (clear = '1') then
                        state <= idle_s;
                    end if;
                
                when stop_s =>
                    if (clear = '1') then
                        state <= idle_s;
                    else
                        case (s) is
                            when "00" => digit <= unit; an <= "11111110";
                            when "01" => digit <= tens; an <= "11111101";
                            when "10" => digit <= hundreds; an <= "11111011";
                            when others => digit <= thousands; an <= "11110111";
                        end case;
                end if;


            end case;
        end if;
    end if;
end process;
	
	process (clk)
	begin
	   if (rising_edge(clk)) then
	       s <= s + 1;
	   end if;
	end process;
	
	process (digit)
	begin
		case (digit) is
			when X"0" => seg <= "1000000"; -- Display 0
			when X"1" => seg <= "1111001"; -- Display 1
			when X"2" => seg <= "0100100"; -- Display 2
			when X"3" => seg <= "0110000"; -- Display 3
			when X"4" => seg <= "0011001"; -- Display 4
			when X"5" => seg <= "0010010"; -- Display 5
			when X"6" => seg <= "0000010"; -- Display 6
			when X"7" => seg <= "1111000"; -- Display 7
			when X"8" => seg <= "0000000"; -- Display 8
			when X"9" => seg <= "0010000"; -- Display 9
			when X"A" => seg <= "0001001"; -- Display H (Changed from A, as it's not being used)
			when X"B" => seg <= "0000011"; -- Display B
			when X"C" => seg <= "1000110"; -- Display C
			when X"D" => seg <= "0100001"; -- Display D
			when X"E" => seg <= "0000110"; -- Display E
			when X"F" => seg <= "0001110"; -- Display F
			when others => seg <= "11111110";	-- Display "-"
		end case;
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
