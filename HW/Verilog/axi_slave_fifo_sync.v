`timescale 1ns/1ps

module axi_slave_fifo_sync#(
    parameter DW = 42,
    parameter AW = 4
)
(
    input   wire            reset_n,
    input   wire            clk,
    output  wire            wr_rdy,
    input   wire            wr_vld,
    input   wire [DW-1:0]   wr_din,
    input   wire            rd_rdy,
    output  wire            rd_vld,
    output  wire [DW-1:0]   rd_dout  
);
localparam DT = 1<<AW;
//register
reg [AW:0] fifo_head;
reg [AW:0] next_head;
reg [AW:0] fifo_tail;
reg [AW:0] next_tail;
reg [AW:0] item_cnt;
reg [DW-1:0] Mem [0:DT-1];
wire full,empty;

//Tail(Write)
always @(posedge clk) begin
    if(!reset_n) begin
        fifo_tail <= 0;
        next_tail <= 1;
    end
    else begin
        if(wr_vld & !full) begin
            fifo_tail <= next_tail;
            next_tail <= next_tail + 1;
        end
    end
end

//Head(Read)
always @(posedge clk) begin
    if(!reset_n) begin
        fifo_head <= 0;
        next_head <= 1;
    end
    else begin
        if(rd_rdy & !empty) begin
            fifo_head <= next_head;
            next_head <= next_head + 1;
        end
    end
end

//item_cnt
always @(posedge clk) begin
    if(!reset_n) begin
        item_cnt <= 0;
    end
    else begin
        if(wr_vld && !full &&(!rd_rdy || (rd_rdy&&empty))) begin//wrtie
            item_cnt <= item_cnt +1;
        end
        else if(rd_rdy && !empty && (!wr_vld || (wr_vld && full))) begin//read
            item_cnt <= item_cnt -1;
        end
    end
end

//write in memory
always@(posedge clk) begin
    if(!full && wr_vld) begin
        Mem[fifo_tail[AW-1:0]] <= wr_din;
    end
end


//internal signal
assign full = item_cnt >= DT;
assign empty = (fifo_head == fifo_tail);

//output
assign wr_rdy = ~full;
assign rd_vld = ~empty;

assign rd_dout = Mem[fifo_head[AW-1:0]];

endmodule

