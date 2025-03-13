library ieee;
use ieee.std_logic_1164.all;


entity Last_Stage is
    generic(BW : integer := 16;
            N : integer := 1);
    port(clk,reset_n,bf_en,valid : in std_logic;
        In_Real, In_Imag : in std_logic_vector(BW-1 downto 0);
        outreal, outimag : out std_logic_vector(BW downto 0)
        );
end Last_Stage;

architecture behav of Last_Stage is
    type arr_re0im1 is array(1 downto 0) of std_logic_vector(BW downto 0);

    signal bf_P,bf_M : arr_re0im1;
    signal Sr_out :arr_re0im1;
    signal mux0,mux1 : arr_re0im1;
    signal w_r_Real,w_r_Imag : std_logic_vector(BW-1 downto 0);

    component d_ff
    generic(N : integer);
    port(clk,reset_n,en : in std_logic;
        d : in std_logic_vector(N-1 downto 0);
        q : out std_logic_vector(N-1 downto 0));
    end component;

    component BF_Calc
    generic(BW : integer);
    port(In_Real, In_Imag, Sr_Real, Sr_Imag : in std_logic_vector(BW-1 downto 0);
        P_Real, P_Imag, M_Real, M_Imag : out std_logic_vector(BW downto 0));
    end component;


    begin
        --Register 
        r_Real : d_ff   generic map(BW)
                        port    map(
                                    clk     => clk,
                                    reset_n => reset_n,
                                    en      => '1',
                                    d       => In_Real,
                                    q       => w_r_Real
                                    );

        r_Imag : d_ff   generic map(BW)
                        port    map(
                                    clk     => clk,
                                    reset_n => reset_n,
                                    en      => '1',
                                    d       => In_Imag,
                                    q       => w_r_Imag
                                    );
      
        --1bit Shift register = normal register
        inst_Sr_Real : d_ff generic map(BW+1)
                            port    map(
                                        clk     => clk,
                                        reset_n => reset_n,
                                        en      => '1',
                                        d       => mux1(0),
                                        q       => Sr_out(0)
                                        );
        inst_Sr_Imag : d_ff generic map(BW+1)
                            port    map(
                                        clk     => clk,
                                        reset_n => reset_n,
                                        en      => '1',
                                        d       => mux1(1),
                                        q       => Sr_out(1)
                                        );
        
        --Butterfly Calc
        bf  : BF_Calc generic map(BW)
                      port  map(
                                In_Real => w_r_Real,
                                In_Imag => w_r_Imag,
                                Sr_Real => Sr_out(0)(BW)&Sr_out(0)(BW-2 downto 0),
                                Sr_Imag => Sr_out(1)(BW)&Sr_out(1)(BW-2 downto 0),
                                
                                P_Real => bf_P(0),
                                P_Imag => bf_p(1),
                                M_Real => bf_M(0),
                                M_Imag => bf_M(1)
                            );
        
        --Mux with BF
        mux0(0) <= bf_P(0) when(bf_en = '1') else Sr_out(0);
        mux0(1) <= bf_P(1) when(bf_en = '1') else Sr_out(1);
        
        mux1(0) <= bf_M(0) when(bf_en = '1') else (w_r_Real(BW-1)&w_r_Real);
        mux1(1) <= bf_M(1) when(bf_en = '1') else (w_r_Imag(BW-1)&w_r_Imag);

        --Output
        outreal <= mux0(0);
        outimag <= mux0(1);

    end behav;