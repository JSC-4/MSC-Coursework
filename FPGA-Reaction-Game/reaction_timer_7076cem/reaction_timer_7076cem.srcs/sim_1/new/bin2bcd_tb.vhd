library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bin2bcd_tb is
end bin2bcd_tb;

architecture Behavioral of bin2bcd_tb is
    signal clk    : std_logic := '0';
    signal clear    : std_logic := '0';
    signal binary_in :  STD_LOGIC_VECTOR(9 DOWNTO 0) := (others => '0');
    signal unit, tens :  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
    signal hundreds, thousands :  STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
constant clk_period : time := 10 ns;
begin

test_proc: entity work.bin2bcd(rtl)
port map(
    clk    => clk,
    clear   => clear,
    binary_in => binary_in,
    unit => unit,
    tens => tens,
    hundreds => hundreds,
    thousands => thousands);
    
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
wait for 100 ns;
binary_in <= "0000000000";
wait for 100 ns;
binary_in <= "0000000001";
wait for 100 ns;
binary_in <= "0000000010";
wait for 100 ns;
binary_in <= "0000000100";
wait for 100 ns;
binary_in <= "0000001000";
wait for 100 ns;
binary_in <= "1111111111";
wait for 100 ns;
binary_in <= "1111111111";
wait for 100 ns;
binary_in <= "0000001010";
wait for 100 ns;
binary_in <= "1100011111";
wait for 100 ns;
binary_in <= "0011111100";
wait for 100 ns;
wait;
end process;


end Behavioral;
