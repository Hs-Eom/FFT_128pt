library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity BF_Calc is
    generic(BW : integer := 16);
    port(
        In_Real, In_Imag : in std_logic_vector(BW-1 downto 0);
        Sr_Real, Sr_Imag : in std_logic_vector(BW-1 downto 0);
    
        P_Real, P_Imag  : out std_logic_vector(BW downto 0);
        M_Real, M_Imag  : out std_logic_vector(BW downto 0)
        );
end BF_Calc;

architecture rtl of BF_Calc is
    begin
    P_Real <= std_logic_vector(resize(signed(Sr_Real), BW+1) + resize(signed(In_Real), BW+1));
    P_Imag <= std_logic_vector(resize(signed(Sr_Imag), BW+1) + resize(signed(In_Imag), BW+1));
    M_Real <= std_logic_vector(resize(signed(Sr_Real), BW+1) - resize(signed(In_Real), BW+1));
    M_Imag <= std_logic_vector(resize(signed(Sr_Imag), BW+1) - resize(signed(In_Imag), BW+1));
end rtl;    
