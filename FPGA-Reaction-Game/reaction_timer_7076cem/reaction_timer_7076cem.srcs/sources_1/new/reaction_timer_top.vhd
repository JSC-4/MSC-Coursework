library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reaction_timer_top is
  Port ( 
    clear, start, stop : in STD_LOGIC;
    clk                : in STD_LOGIC;
    an                 : out STD_LOGIC_VECTOR(7 downto 0);
    seg                : out STD_LOGIC_VECTOR(6 downto 0);
    LED                : out STD_LOGIC);
end reaction_timer_top;

architecture rtl of reaction_timer_top is
    signal clk_out, refresh : STD_LOGIC := '0';
    signal stop_sig, en : STD_LOGIC := '0';
    signal clear_sig : STD_LOGIC := '0';
    signal rng_clk       : STD_LOGIC := '0';
    signal counter : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others => '0');
    signal unit, tens :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal hundreds, thousands : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal count_val : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    signal start_sig, rng_start, done : STD_LOGIC := '0';
    signal start_button : STD_LOGIC := '0';
begin

clk_1_ms : entity work.clk_div(rtl)
    generic map (N => 500000) -- set back to 5000000
    port map (
      clk => clk,
      clear => clear,
      clk_out => clk_out
    );

ssd_refresh : entity work.clk_div(rtl)
    generic map (N => 300000)
    port map (
      clk => clk,
      clear => clear,
      clk_out => refresh
    );

clk_1_sec : entity work.clk_div(rtl)
    generic map (N => 50000000)
    port map (
      clk => clk,
      clear => clear,
      clk_out => rng_clk
    );
            
counter_10bit : entity work.mbit_counter(rtl)
    generic map (N => 9)
    port map (
      clk => clk_out,
      clear => clear,
      stop => stop,
      clear_sig => clear_sig,
      stop_sig => stop_sig,
      en => en,
      count_out => counter
    );
    
bin2bcd : entity work.bin2bcd(rtl)
    port map (
      clk => clk_out,
      clear => clear,
      binary_in => counter,
      unit => unit,
      tens => tens,
      hundreds => hundreds,
      thousands => thousands
    );

--ssd_controller : entity work.seven_seg_controller(rtl)
--    port map (
--      clk => refresh,
--      clear => clear,
--      clear_sig => clear_sig,
--      unit => unit,
--      tens => tens,
--      hundreds => hundreds,
--      thousands => thousands,
--      seg => seg,
--      an => an
--    );
    
--main : entity work.reaction_timer(rtl)
--    port map (
--      clk => clk,
--      clear => clear,
--      start => start_button,
--      done => done,
--      clear_sig => clear_sig,
--      stop_sig => stop_sig,
--      count_val => count_val,
--      en => en,
--      rng_start => rng_start,
--      LED => LED
--    );

rng : entity work.rng_counter(rtl)
    port map (
      clk => rng_clk,
      clear => clear,
      count_val => count_val,
      start_sig => rng_start,
      done => done
    );

reaction : entity work.reaction(rtl)
    port map (
      clk => refresh,
      clear => clear,
      start => start,
      stop => stop,
      rng_done => done,
      clear_sig => clear_sig,
      unit => unit,
      tens => tens,
      hundreds => hundreds,
      thousands => thousands,
      seg => seg,
      an => an,
      count_val => count_val,
      start_rng => rng_start,
      start_counter => en,
      LED => LED
    );

--dbStart : entity work.debounce(rtl)
--    port map (
--      clk => clk,
--      reset => clear,
--      button_in => start,
--      pulse_out => start_button
--      );
           

end rtl;
