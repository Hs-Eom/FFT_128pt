library ieee;
use ieee.std_logic_1164.all;

entity d_ff is
    generic(N : integer := 1);
    port(
        clk ,reset_n, en : in std_logic;
        d : in std_logic_vector(N-1 downto 0);
        q : out std_logic_vector(N-1 downto 0)
    );
end d_ff;

architecture behav of d_ff is
    begin
        process(clk) begin
            if(clk'event and clk = '1') then
                if(en = '1')then
                    if(reset_n = '0') then
                        q <= (others => '0');
                    else
                        q <= d;
                    end if;
                end if;
            end if;
        end process;
    end behav;


