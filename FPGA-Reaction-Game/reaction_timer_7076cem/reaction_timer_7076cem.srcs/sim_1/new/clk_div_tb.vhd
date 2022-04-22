library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div_tb is
end clk_div_tb;

architecture Behavioral of clk_div_tb is
    signal clk    : std_logic := '0';
    signal clear    : std_logic := '0';
    signal clk_out    : std_logic;

constant clk_period : time := 10 ns;

begin

test_proc: entity work.clk_div(rtl)
generic map(N => 50000)
port map(
    clk    => clk,
    clear   => clear,
    clk_out => clk_out);
    
clk_proc: process
begin
clk <= '0';
wait for clk_period / 2;
clk <= '1';
wait for clk_period / 2;
end process;
    
stim_proc: process
begin
wait for 100 ns;
clear <= '1';
wait for 100 ns;
clear <= '0';
wait;
end process;

end Behavioral;
