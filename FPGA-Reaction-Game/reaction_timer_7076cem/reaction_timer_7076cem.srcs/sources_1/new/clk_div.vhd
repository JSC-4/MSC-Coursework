library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
    Generic (N : integer);
    Port ( clk : in STD_LOGIC;
           clear : in STD_LOGIC;
           clk_out : out STD_LOGIC);
end clk_div;

architecture rtl of clk_div is
    signal counter : integer range 0 to N := 0;
    signal temp    : std_logic := '0';
begin

process (clk, clear)
begin
    if (clear = '1') then
        counter <= 0;
        temp <= '0';
    elsif (rising_edge(clk)) then
          counter <= counter + 1;
          if (counter = N) then
            temp <= NOT temp;
            counter <= 0;
          end if;
    end if;
    
    clk_out <= temp;
end process;

end rtl;
