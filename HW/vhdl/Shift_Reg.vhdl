library ieee;
use ieee.std_logic_1164.all;

entity Shift_Reg is
    generic(BW : integer := 16;
            N : integer := 64
    );
    port(
        clk,reset_n,valid : in std_logic;
        In_Data: in std_logic_vector(BW downto 0);

        Out_Data: out std_logic_vector(BW downto 0)
    );
end Shift_Reg;

architecture behav of Shift_Reg is
    type arr is array(N-1 downto 0) of std_logic_vector(BW downto 0); 
    signal sr : arr;
    
    begin
        -- 1.Sr(0) opeartion
        process(clk) begin
            if(clk'event and clk = '1') then
                if(reset_n ='0') then
                    reset_arr : for i in 0 to N-1 loop
                        sr(i) <= (others=>'0');
                    end loop;
                elsif(valid = '1') then
                    sr(0) <= In_Data;
                    push : for i in 1 to N-1 loop
                        sr(i) <= sr(i-1);
                    end loop;
                end if;
            end if;
        end process;

        --Output
        Out_Data <= sr(N-1);
    end behav;
