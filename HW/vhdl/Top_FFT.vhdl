library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

entity Top_FFT is
    generic(In_BW : integer := 16;
            Out_BW : integer := 23;
            Cut_BW : integer := 7;
            N: integer := 128);
    port(clk, reset_n, valid, start : in std_logic;
        In_Real, In_Imag : in std_logic_vector(In_BW-1 downto 0);
        Out_Real, Out_Imag : out std_logic_vector((Out_BW- Cut_BW)-1 downto 0));
end Top_FFT;

architecture behav of Top_FFT is
    --wire declare
    constant cnt_width : integer := integer(log2(Real(N))); -- 7
    signal w_cnt : std_logic_vector(cnt_width-1 downto 0);
    signal w_en_s1,w_en_s2,w_en_s3,w_en_s4,w_en_s5,w_en_s6,w_en_s7 : std_logic;

    --array declare
    type sig_arr1 is array(1 downto 0) of std_logic_vector(In_BW   downto 0);
    type sig_arr2 is array(1 downto 0) of std_logic_vector(In_BW+1 downto 0);
    type sig_arr3 is array(1 downto 0) of std_logic_vector(In_BW+2 downto 0);
    type sig_arr4 is array(1 downto 0) of std_logic_vector(In_BW+3 downto 0);
    type sig_arr5 is array(1 downto 0) of std_logic_vector(In_BW+4 downto 0);
    type sig_arr6 is array(1 downto 0) of std_logic_vector(In_BW+5 downto 0);
    type sig_arr7 is array(1 downto 0) of std_logic_vector(In_BW+6 downto 0);

    signal sig1 : sig_arr1;
    signal sig2 : sig_arr2;
    signal sig3 : sig_arr3;
    signal sig4 : sig_arr4;
    signal sig5 : sig_arr5;
    signal sig6 : sig_arr6;
    signal sig7 : sig_arr7;
    ------------------------------------
    
    component Counter
    generic(num: integer); 
    port(clk, reset_n, valid, start : in std_logic;
        cnt : out std_logic_vector(num-1 downto 0));
    end component;

    component BF_En_Gen
    generic(N : integer);
    port(cnt_1 : in std_logic_vector(N-1 downto 0);
        en_s1,en_s2,en_s3,en_s4,en_s5,en_s6,en_s7 : out std_logic);
    end component;

    component Stage
    generic(BW,N : integer);
    port(clk, reset_n, valid, bf_en : in std_logic;
        cnt : in std_logic_vector(5 downto 0);
        In_Real, In_Imag : in std_logic_vector(BW-1 downto 0);
        Out_Real, Out_Imag : out std_logic_vector(BW downto 0));
    end component;

    component Last_Stage
    generic(BW, N : integer);
    port(clk, reset_n, valid, bf_en : in std_logic;
        In_Real, In_Imag : in std_logic_vector(BW-1 downto 0);
        outreal, outimag : out std_logic_vector(BW downto 0));
    end component;

    begin

    inst_Counter : Counter   generic map(cnt_width) --7
                        port map(
                                clk => clk,
                                reset_n => reset_n,
                                valid => valid, 
                                start => start,
                                cnt => w_cnt);
    
    --BF_Enable_Generator                            
    BF_Gen : BF_En_Gen  generic map(cnt_width)
                        port map(
                                cnt_1 => w_cnt,
                                en_s1 => w_en_s1, 
                                en_s2 => w_en_s2, 
                                en_s3 => w_en_s3,
                                en_s4 => w_en_s4, 
                                en_s5 => w_en_s5,
                                en_s6 => w_en_s6,
                                en_s7 => w_en_s7
                        );
    
    --Stage1
    Stage1 : Stage  generic map(In_BW, 64)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s1, 
                        cnt     => w_cnt(5 downto 0),
                        In_Real => In_Real,
                        In_Imag => In_Imag,
                            
                        Out_Real=> sig1(0),
                        Out_Imag=> sig1(1)
                        );

    Stage2 : Stage  generic map(In_BW+1, 32)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s2, 
                        cnt     => w_cnt(4 downto 0)&"0",
                        In_Real => sig1(0),
                        In_Imag => sig1(1),
                            
                        Out_Real=> sig2(0),
                        Out_Imag=> sig2(1)
                        );

    Stage3 : Stage  generic map(In_BW+2, 16)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s3, 
                        cnt     => w_cnt(3 downto 0)&"00",
                        In_Real => sig2(0),
                        In_Imag => sig2(1),
                            
                        Out_Real=> sig3(0),
                        Out_Imag=> sig3(1)
                        );

    Stage4 : Stage  generic map(In_BW+3, 8)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s4, 
                        cnt     => w_cnt(2 downto 0)&"000",
                        In_Real => sig3(0),
                        In_Imag => sig3(1),
                            
                        Out_Real=> sig4(0),
                        Out_Imag=> sig4(1)
                        );

    Stage5 : Stage  generic map(In_BW+4, 4)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s5, 
                        cnt     => w_cnt(1 downto 0)&"0000",
                        In_Real => sig4(0),
                        In_Imag => sig4(1),
                            
                        Out_Real=> sig5(0),
                        Out_Imag=> sig5(1)
                        );

    Stage6 : Stage  generic map(In_BW+5, 2)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s6, 
                        cnt     => w_cnt(0)&"00000",
                        In_Real => sig5(0),
                        In_Imag => sig5(1),
                            
                        Out_Real=> sig6(0),
                        Out_Imag=> sig6(1)
                        );
    
    Stage7 : Last_Stage generic map(In_BW+6, 1)
                    port map(
                        clk     => clk, 
                        reset_n => reset_n, 
                        valid   => valid, 
                        bf_en   => w_en_s7, 

                        In_Real => sig6(0),
                        In_Imag => sig6(1),
                            
                        outreal=> sig7(0),
                        outimag=> sig7(1)
                        );
    
    --Output
    Out_Real <= sig7(0)(Out_BW-1 downto Cut_BW);
    Out_Imag <= sig7(1)(Out_BW-1 downto Cut_BW);

    end behav;

