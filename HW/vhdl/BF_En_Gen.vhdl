library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BF_En_Gen is
    generic(N : integer := 7);
    port(
        cnt_1 : in std_logic_vector(N-1 downto 0);

        en_s1, en_s2, en_s3, en_s4 : out std_logic;
        en_s5, en_s6, en_s7 : out std_logic
    );
end BF_En_Gen;

architecture rtl of BF_En_Gen is
    signal cnt_2 : std_logic_vector(N-1 downto 0);
    signal cnt_3 : std_logic_vector(N-1 downto 0);
    signal cnt_4 : std_logic_vector(N-1 downto 0);
    signal cnt_5 : std_logic_vector(N-1 downto 0);
    signal cnt_6 : std_logic_vector(N-1 downto 0);
    signal cnt_7 : std_logic_vector(N-1 downto 0);
    begin
        cnt_2 <= std_logic_vector(unsigned(cnt_1) - 1);
        cnt_3 <= std_logic_vector(unsigned(cnt_2) - 1);
        cnt_4 <= std_logic_vector(unsigned(cnt_3) - 1);
        cnt_5 <= std_logic_vector(unsigned(cnt_4) - 1);
        cnt_6 <= std_logic_vector(unsigned(cnt_5) - 1);
        cnt_7 <= std_logic_vector(unsigned(cnt_6) - 1);

        en_s1 <= cnt_1(6);
        en_s2 <= cnt_2(5);
        en_s3 <= cnt_3(4);
        en_s4 <= cnt_4(3);
        en_s5 <= cnt_5(2);
        en_s6 <= cnt_6(1);
        en_s7 <= cnt_7(0);
    end rtl;
