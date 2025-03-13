library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity Counter is
    generic(
        num : integer := integer(log2(real(128))));
    port(
        clk,reset_n : in std_logic;
        valid, start : in std_logic;

        cnt : out std_logic_vector(num-1 downto 0)
    );
end Counter;

architecture behav of Counter is
    signal tmp_cnt : unsigned(num-1 downto 0);
    begin
        process(clk) begin
            if(clk'event and clk = '1') then
                if(reset_n = '0') then
                    tmp_cnt <= (others => '1');
                elsif(start = '0') then
                    tmp_cnt <= (others => '1');
                elsif(valid = '1') then
                    tmp_cnt <= tmp_cnt + 1;
                end if;
            end if;
        end process;
        cnt <= std_logic_vector(tmp_cnt);
    end behav;

