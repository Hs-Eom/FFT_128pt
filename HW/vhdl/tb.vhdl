library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_fft is
end tb_fft;

architecture test of tb_fft is
    component Top_FFT
    generic(In_BW, Out_Bw, Cut_BW, N : integer);
    port(clk, reset_n, start, valid : in std_logic;
        In_Real, In_Imag : in std_logic_vector(In_BW-1 downto 0);
        Out_Real, Out_Imag : out std_logic_vector((Out_BW - Cut_BW)-1 downto 0)
    );
    end component;
    
    --constant, ctrl signal declare
    constant t_size : integer := 1+384+128+140;
    signal clk_tb, reset_n_tb : std_logic;

    --input_vector(0~383)
    type in_arr is array(0 to 383) of std_logic_vector(15 downto 0);
    signal input_re : in_arr;
    signal input_im : in_arr;

    --output_vector(0~653)
    type out_arr is array(0 to t_size) of std_logic_vector(15 downto 0);
    signal output_re : out_arr;
    signal output_im : out_arr;
    
    --test_bench Signal
    signal inReal,inImag : std_logic_vector(15 downto 0);
    signal outReal,outImag : std_logic_vector(15 downto 0);

    signal clkcnt : integer := -4;
    signal start : std_logic := '0';

    constant clk_period : time := 10 ns;
    constant reset_duration : time := 6 ns;

    --File variable
    file r_rvect, r_ivect : text; --read vectors
    file w_rvect, w_ivect : text; --wirte vectors


    begin

    --Top_FFT instantiation
    DUT : Top_FFT   generic map(16, 23, 7 , 128)
                    port map(clk => clk_tb,
                            reset_n=> reset_n_tb,
                            valid => '1', 
                            start => start,
                            In_Real => inReal,
                            In_Imag => inImag,
                            Out_Real => outReal,
                            Out_Imag => outImag);
    -------------------------------------------------------
    --Clk_genenration_whenveer 10 ns
    clk_10ns : process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
            end loop;
         wait;
    end process;

    ---------------------------------------------------------
    --start process: start = '1' when 10ns(clk_period)
    start_proc : process
    begin
        wait for clk_period;
        start <= '1';
        wait;
    end process;
    
    -----------------------------------------------------------
    --Clk counting process to put in a in/out_array
    clk_counting : process(clk_tb)
    begin
        if(clk_tb'event and clk_tb = '0') then
            clkcnt <= clkcnt + 1;
        end if;
    end process;

    -----------------------------------------------------------
    --ReSet_Process when reset_duration
    reset_proc : process
    begin
        reset_n_tb <= '0';
        wait for reset_duration;
        reset_n_tb <= '1';
        wait; --end of the process
    end process;

    ----------------------------------------------------------
    --Read File process: Read data from an input_file and store it in an array
    R_File: process
    variable r_rline,r_iline : line;
    variable r_rdata,r_idata : std_logic_vector(15 downto 0);
    variable i : integer := 0;
    begin
        file_open(r_rvect, "/home/ehs/Src/portfolio/binary_in_real.txt", read_mode);
        file_open(r_ivect, "/home/ehs/Src/portfolio/binary_in_imag.txt", read_mode);
        while (not endfile(r_rvect)) and  (not endfile(r_ivect)) loop
            readline(r_rvect, r_rline);
            readline(r_ivect, r_iline);
            read(r_rline, r_rdata);
            read(r_iline, r_idata);
            if i <= 383 then
                input_re(i) <= r_rdata;
                input_im(i) <= r_idata;
            end if;
            i := i + 1;
        end loop;
        file_close(r_rvect);
        file_close(r_ivect);
        wait;
    end process;
    -----------------------------------------------------------------------------------------
    --Storing an array(inReal,inImag) when 382 > clk_cnt >= -2
    inReal <= (others => '0') when (clkcnt <= -2 or clkcnt > 382) else input_re(clkcnt+1);
    inImag <= (others => '0') when (clkcnt <= -2 or clkcnt > 382) else input_im(clkcnt+1);

    -------------------------------------------------------------------------------------------
    --Output process
    o_data: process(clk_tb)
    begin
        if(clk_tb'event and clk_tb = '1') then
            if(clkcnt + 1) >= 0 and (clkcnt+1) <= t_size then
                output_re(clkcnt+1) <= outReal;
                output_im(clkcnt+1) <= outImag;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------
    --Write file process
    W_File : process
    variable w_rline,w_iline : line;
    variable w_rdata,w_idata :std_logic_vector(15 downto 0);
    variable j : integer := 0;
    constant o_time : time := (t_size * clk_period)+ 1 ns;
    begin
        wait for o_time;
        file_open(w_rvect,"binary_out_real.txt", write_mode);
        file_open(w_ivect,"binary_out_imag.txt", write_mode);

        for j in 0 to t_size loop
            w_rdata := output_re(j);
            w_idata := output_im(j);
            write(w_rline, w_rdata);
            write(w_iline, w_idata);
            writeline(w_rvect, w_rline);
            writeline(w_ivect, w_iline);
        end loop ;
        file_close(w_rvect);
        file_close(w_ivect);

        wait;
    end process;
    -----------------------------------------------------------
    ---Stop Simulation
    simulation_stop : process
    begin
        wait for (t_size * clk_period) + 100 ns;
        assert false report "Simulation finished" severity note;
        wait;
    end process;

    end test;


