library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_slave_fifo_sync is
    generic(DW : integer := 42;
            AW : integer := 4);
    port(clk, reset_n : in std_logic;
        wr_rdy : out std_logic;
        wr_vld : in std_logic;
        wr_din : in std_logic_vector(DW-1 downto 0);
        rd_rdy : in std_logic;
        rd_vld : out std_logic;
        rd_dout : out std_logic_vector(DW-1 downto 0)
    );
end axi_slave_fifo_sync;

architecture behav of axi_slave_fifo_sync is
    constant DT :integer := to_integer((to_unsigned(1,AW+1) sll AW));
    signal fifo_head : std_logic_vector(AW downto 0);
    signal next_head : std_logic_vector(AW downto 0);
    signal fifo_tail : std_logic_vector(AW downto 0);
    signal next_tail : std_logic_vector(AW downto 0);
    signal item_cnt : std_logic_vector(AW downto 0);
    type Mem_arr is array(0 to DT-1) of std_logic_vector(DW-1 downto 0);
    signal Mem : Mem_arr;
    signal full, empty : std_logic;
begin
    --Tail(Write)
    W_Tail : process(clk) begin
        if(clk'event and clk = '1') then
            if(reset_n = '0') then
                fifo_tail <= (others => '0');
                next_tail <= std_logic_vector(to_unsigned(1,AW+1));
            elsif((wr_vld ='1') and (full /= '1')) then
                fifo_tail <= next_tail;
                next_tail <= std_logic_vector(unsigned(next_tail) + 1);
            end if;
        end if;
    end process; -- W_Tail

    R_Head : process(clk)
    begin
        if(clk'event and clk='1') then
            if(reset_n = '0') then
                fifo_head <= (others => '0');
                next_head <= std_logic_vector(to_unsigned(1,AW+1));
            elsif((rd_rdy='1') and (empty /= '1')) then
                fifo_head <= next_head;
                next_head <= std_logic_vector(unsigned(next_head)+1);
            end if;
        end if;
    end process ; -- R_Head

    Item_cnt_proc : process(clk)
    begin
        if(clk'event and clk = '1') then
            if(reset_n = '0') then
                item_cnt <= (others => '0');
            elsif((wr_vld = '1') and (full /= '1') and ((rd_rdy /= '1') or ((rd_rdy ='1') and (empty='1')))) then
                item_cnt <= std_logic_vector(unsigned(item_cnt)+1);
            elsif((rd_rdy='1') and (empty /= '1') and ((wr_vld /= '1') or ((wr_vld='1') and (full='1')))) then
                item_cnt <= std_logic_vector(unsigned(item_cnt)-1);
            end if;
        end if;
    end process; -- Item cnt

    W_Mem : process(clk)
    begin
        if(clk'event and clk ='1') then
            if((full /= '1') and (wr_vld='1')) then
                Mem(to_integer(unsigned(fifo_tail(AW-1 downto 0)))) <= wr_din;
            end if;
        end if;
    end process;

    --internal signal
    full <=  '1' when (to_integer(unsigned(item_cnt)) >= DT) else '0';
    empty <= '1' when (unsigned(fifo_head) = unsigned(fifo_tail)) else '0';

    --Output
    wr_rdy <= not(full);
    rd_vld <= not(empty);
    rd_dout <= Mem(to_integer(unsigned(fifo_head(AW-1 downto 0))));

    end behav;
    
