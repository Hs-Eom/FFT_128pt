module BF_En_Gen#(
    parameter N = 7
)
(
    input wire [N-1:0] cnt_1,

    output wire en_s1,
    output wire en_s2,
    output wire en_s3,
    output wire en_s4,
    output wire en_s5,
    output wire en_s6,
    output wire en_s7
);

//declare wire
wire [N-1:0] cnt_2= cnt_1 - 1;
wire [N-1:0] cnt_3= cnt_2 - 1;
wire [N-1:0] cnt_4= cnt_3 - 1;
wire [N-1:0] cnt_5= cnt_4 - 1;
wire [N-1:0] cnt_6= cnt_5 - 1;
wire [N-1:0] cnt_7= cnt_6 - 1;

assign cnt_2 = cnt_1 - 1;
assign cnt_3 = cnt_2 - 1;
assign cnt_4 = cnt_3 - 1;
assign cnt_5 = cnt_4 - 1;
assign cnt_6 = cnt_5 - 1;
assign cnt_7 = cnt_6 - 1;

assign en_s1 = cnt_1[6];
assign en_s2 = cnt_2[5];
assign en_s3 = cnt_3[4];
assign en_s4 = cnt_4[3];
assign en_s5 = cnt_5[2];
assign en_s6 = cnt_6[1];
assign en_s7 = cnt_7[0];

endmodule
