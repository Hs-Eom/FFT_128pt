library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity axi_slave_FFT_f_ps is
    generic(WIDTH_SID : integer := 15;
            WIDTH_AD : integer := 14;
            WIDTH_DA : integer := 32;
            WIDTH_DS : integer := 4);
    port(S_AXI_ACLK : in std_logic;
         S_AXI_ARESETN : in std_logic;                      
                             
         S_AXI_AWID : in std_logic_vector(WIDTH_SID-1 downto 0); 
         S_AXI_AWADDR : in std_logic_vector(WIDTH_AD-1 downto 0); 
         S_AXI_AWLEN : in std_logic_vector(7 downto 0);
         S_AXI_AWLOCK : in std_logic;                       
         S_AXI_AWSIZE : in std_logic_vector(2 downto 0);
         S_AXI_AWBURST : in std_logic_vector(1 downto 0);
         S_AXI_AWVALID : in std_logic;                      
         S_AXI_AWREADY : out std_logic;                      
                             
         S_AXI_WID : in std_logic_vector(WIDTH_SID-1 downto 0); 
         S_AXI_WDATA : in std_logic_vector(WIDTH_DA-1 downto 0);
         S_AXI_WSTRB : in std_logic_vector(WIDTH_DS-1 downto 0);
         S_AXI_WLAST : in std_logic;                        
         S_AXI_WVALID : in std_logic;                       
         S_AXI_WREADY : out std_logic;                       
                             
         S_AXI_BID : out std_logic_vector(WIDTH_SID-1 downto 0);
         S_AXI_BRESP : out std_logic_vector(1 downto 0);
         S_AXI_BVALID : out std_logic;                       
         S_AXI_BREADY : in std_logic;                       
                             
         S_AXI_ARID : in std_logic_vector(WIDTH_SID-1 downto 0);
         S_AXI_ARADDR : in std_logic_vector(WIDTH_AD-1 downto 0);
         S_AXI_ARLEN : in std_logic_vector(7 downto 0);
         S_AXI_ARLOCK : in std_logic;                       
         S_AXI_ARSIZE : in std_logic_vector(2 downto 0);
         S_AXI_ARBURST : in std_logic_vector(1 downto 0); -- Info: Burst size selectio is not supported
         S_AXI_ARVALID : in std_logic;                      
         S_AXI_ARREADY : out std_logic;                      
                             
         S_AXI_RID : out std_logic_vector(WIDTH_SID-1 downto 0);
         S_AXI_RDATA : out std_logic_vector(WIDTH_DA-1 downto 0); 
         S_AXI_RRESP : out std_logic_vector(1 downto 0);   
         S_AXI_RLAST : out std_logic;                        
         S_AXI_RVALID : out std_logic;                       
         S_AXI_RREADY : in std_logic             
    );
end axi_slave_FFT_f_ps;

architecture behav of axi_slave_FFT_f_ps is
    --WFIFO Signals
    signal W_wr_vld : std_logic;
    Signal W_rd_rdy : std_logic;
    signal W_rd_vld : std_logic;
    --RFIFO Signals
    signal R_wr_vld : std_logic;
    signal R_rd_rdy : std_logic;
    signal R_rd_vld : std_logic;
    --AW Signals
    signal awid : std_logic_vector(WIDTH_SID-1 downto 0);
    
    --internal signal from output port
    signal S_AXI_AWREADY_int : std_logic;
    signal S_AXI_WREADY_int  : std_logic;
    signal S_AXI_ARREADY_int : std_logic;
    signal S_AXI_RLAST_int   : std_logic;
    signal S_AXI_RVALID_int  : std_logic;

    --IP Start Signals
    signal start_FFT : std_logic;
    signal valid_int : std_logic;

    component axi_slave_fifo_sync
    generic(DW,AW : integer);
    port(clk, reset_n : in std_logic;
        wr_rdy : out std_logic;
        wr_vld : in std_logic;
        wr_din : in std_logic_vector(DW-1 downto 0);
        rd_rdy : in std_logic;
        rd_vld : out std_logic;
        rd_dout : out std_logic_vector(DW-1 downto 0));
    end component;

    component Top_FFT
    generic(In_BW, Out_Bw, Cut_BW, N : integer);
    port(clk, reset_n, start, valid : in std_logic;
        In_Real, In_Imag : in std_logic_vector(In_BW-1 downto 0);
        Out_Real, Out_Imag : out std_logic_vector((Out_BW - Cut_BW)-1 downto 0)
    );
    end component;

    begin
    ------Channel Description-------
    --internal signal from output
    S_AXI_AWREADY <= S_AXI_AWREADY_int;
    S_AXI_WREADY  <= S_AXI_WREADY_int;
    S_AXI_ARREADY <= S_AXI_ARREADY_int;
    S_AXI_RLAST   <= S_AXI_RLAST_int;
    S_AXI_RVALID <= S_AXI_RVALID_int;

    ----AW Chaneel
    W_wr_vld <= S_AXI_AWVALID and S_AXI_AWREADY_int;

    --W Channel
    S_AXI_WREADY_int <= W_rd_vld;	-- for single beat
    W_rd_rdy <= S_AXI_WLAST and S_AXI_WVALID and S_AXI_WREADY_int;	-- W transaction expired

    --B Channel
    process(S_AXI_ACLK) begin
        if(S_AXI_ACLK'event and S_AXI_ACLK = '1') then
            if(S_AXI_ARESETN = '0') then
                S_AXI_BID <= (others => '0');
            elsif((S_AXI_WLAST='1') and (S_AXI_WVALID='1') and (S_AXI_WREADY_int='1')) then
                S_AXI_BID <= awid;
            end if;
        end if;
    end process;

    process(S_AXI_ACLK) begin
        if(S_AXI_ACLK'event and S_AXI_ACLK = '1') then
            if(S_AXI_ARESETN = '0') then
                S_AXI_BVALID <= '0';
            elsif((S_AXI_WLAST='1') and (S_AXI_WVALID='1') and (S_AXI_WREADY_int='1')) then
                S_AXI_BVALID <= '1';
            elsif(S_AXI_BREADY='1') then
                S_AXI_BVALID <= '0';
            end if;
        end if;
    end process;

    S_AXI_BRESP <= "00";

    --AW Channel
    R_wr_vld <= S_AXI_ARVALID and S_AXI_ARREADY_int;

    --R Channel
    S_AXI_RVALID_int <= R_rd_vld ;	-- for single beat burst
    S_AXI_RLAST_int  <= R_rd_vld;

    S_AXI_RRESP  <= "00";

    R_rd_rdy <= S_AXI_RLAST_int and S_AXI_RVALID_int and S_AXI_RREADY;	-- R transaction expired
----------------------------------------------------------------------------

------------FIFO--------------------------------------------------------------------------
WFIFO : axi_slave_fifo_sync generic map(15, 1)
                            port map(
                                    clk => S_AXI_ACLK,
                                    reset_n => S_AXI_ARESETN, 
                                    wr_rdy => S_AXI_AWREADY_int,
                                    wr_vld => W_wr_vld, 
                                    wr_din => S_AXI_AWID, 
                                    rd_rdy => W_rd_rdy, 
                                    rd_vld => W_rd_vld, 
                                    rd_dout => awid
                                    );

RFIFO : axi_slave_fifo_sync generic map(15, 1)
                            port map(
                                    clk => S_AXI_ACLK,
                                    reset_n => S_AXI_ARESETN, 
                                    wr_rdy => S_AXI_ARREADY_int,
                                    wr_vld => R_wr_vld, 
                                    wr_din => S_AXI_ARID, 
                                    rd_rdy => R_rd_rdy, 
                                    rd_vld => R_rd_vld, 
                                    rd_dout => S_AXI_RID
                                    );
------------------------------------------------------------------------------------------

-------IP(FFT) Description--------------
start_FFT <= '1' when (S_AXI_WDATA /= X"7FFFFFFF") else '0';
valid_int <= S_AXI_WREADY_int and S_AXI_WVALID;
inst_FFT : Top_FFT  generic map(16, 23, 7, 128)
                    port    map(clk => S_AXI_ACLK, 
                                reset_n => start_FFT, 
                                start => start_FFT,
                                valid => valid_int,
                                In_Real => S_AXI_WDATA(31 downto 16), 
                                In_Imag => S_AXI_WDATA(15 downto 0),
                                Out_Real => S_AXI_RDATA(31 downto 16), 
                                Out_Imag => S_AXI_RDATA(15 downto 0)
                                );

end behav;

