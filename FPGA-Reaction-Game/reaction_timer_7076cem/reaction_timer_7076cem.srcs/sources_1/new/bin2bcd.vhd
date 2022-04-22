library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin2bcd is
    Port ( clk : in STD_LOGIC;
           clear : in STD_LOGIC;
           binary_in : in STD_LOGIC_VECTOR(9 DOWNTO 0);
           unit, tens : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           hundreds, thousands : out STD_LOGIC_VECTOR(3 DOWNTO 0));
end bin2bcd;

architecture rtl of bin2bcd is
begin

process (clk, clear)
variable x : UNSIGNED(25 DOWNTO 0);
begin
    for i in 0 to 25 loop
        x(i) := '0';
    end loop;
    -- Do the first initial shift 
    x(12 downto 3) := unsigned(binary_in);
    -- Loop seven times 
    for i in 0 to 6 loop     
        -- Check units
        if x(13 downto 10) > 4 then
            x(13 downto 10) := x(13 downto 10) + 3;
        end if;
        -- Check tens
        if x(17 downto 14) > 4 then
            x(17 downto 14) := x(17 downto 14) + 3;
        end if;
        -- Check hundreths
        if x(21 downto 18) > 4 then
            x(21 downto 18) := x(21 downto 18) + 3;
        end if;
         -- Check thousands
        if x(25 downto 22) > 4 then
            x(25 downto 22) := x(25 downto 22) + 3;
        end if;
      
        x(25 downto 1) := x(24 downto 0);
    end loop;
 
    unit <= std_logic_vector(x(13 downto 10));   
    tens <= std_logic_vector(x(17 downto 14));    
    hundreds <= std_logic_vector(x(21 downto 18));    
    thousands <= std_logic_vector(x(25 downto 22)); 
        
end process;

end rtl;
