library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_controller is
  Port ( 
        clk, clear : in STD_LOGIC;
        clear_sig : in STD_LOGIC;
        unit, tens : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        hundreds, thousands : in STD_LOGIC_VECTOR(3 DOWNTO 0);
        seg : out  STD_LOGIC_VECTOR (6 downto 0);
        an : out  STD_LOGIC_VECTOR (7 downto 0));
end seven_seg_controller;

architecture rtl of seven_seg_controller is
	SIGNAL digit : STD_LOGIC_VECTOR (3 downto 0);
    SIGNAL s	: UNSIGNED(1 downto 0) := "00";
begin

	process (s)
	begin
        if (clear_sig = '1') then
            case (s) is
                when "00" => digit <= (others => '0'); an <= "11111111";
                when "01" => digit <= (others => '0'); an <= "11111111";
                when "10" => digit <= X"1"; an <= "11111011";
                when others => digit <= X"A"; an <= "11110111";
            end case;
        else
            case (s) is
                when "00" => digit <= unit; an <= "11111110";
                when "01" => digit <= tens; an <= "11111101";
                when "10" => digit <= hundreds; an <= "11111011";
                when others => digit <= thousands; an <= "11110111";
            end case;
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


end rtl;
