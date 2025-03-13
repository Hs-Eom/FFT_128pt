module Top_FFT#(
    parameter In_BW = 16,
    parameter Out_BW = 23,
    parameter Cut_BW = 7,
    parameter N = 128
)
(
    input wire clk,
    input wire reset_n,
    input wire valid,
    input wire start,
    input wire [In_BW-1:0] In_Real,
    input wire [In_BW-1:0] In_Imag,

    output wire [(Out_BW - Cut_BW)-1:0] Out_Real,
    output wire [(Out_BW - Cut_BW)-1:0] Out_Imag
);

//wire declare
localparam num = $clog2(N);
wire [num-1:0] cnt; //7bit
wire en_s1,en_s2,en_s3,en_s4,en_s5,en_s6,en_s7;
wire [In_BW  :0] sig1[1:0];
wire [In_BW+1:0] sig2[1:0];
wire [In_BW+2:0] sig3[1:0];
wire [In_BW+3:0] sig4[1:0];
wire [In_BW+4:0] sig5[1:0];
wire [In_BW+5:0] sig6[1:0];
wire [In_BW+6:0] sig7[1:0];

//Coutner
Counter#(.N(N))
Counter(
    .clk        (clk),
    .reset_n    (reset_n),
    .valid      (valid),
    .start      (start),

    .cnt        (cnt)
);

//BF_Enable_Generator
BF_En_Gen#(.N(num))
BF_Gen(
    .cnt_1      (cnt),

    .en_s1      (en_s1),
    .en_s2      (en_s2),
    .en_s3      (en_s3),
    .en_s4      (en_s4),
    .en_s5      (en_s5),
    .en_s6      (en_s6),
    .en_s7      (en_s7)
);


//Stage1 
Stage#(.BW(In_BW), .N(64)) 
Stage1(
  	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s1),
	.cnt		(cnt[5:0]),
	.valid		(valid),
	.In_Real	(In_Real),
	.In_Imag	(In_Imag),
	
	.Out_Real	(sig1[0]),
	.Out_Imag	(sig1[1])
);

//Stage2
Stage#(.BW(In_BW+1),.N(32)) 
Stage2(
	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s2),
	.cnt		({cnt[4:0],1'b0}),
	.valid		(valid),
	.In_Real	(sig1[0]),
	.In_Imag	(sig1[1]),
	
	.Out_Real	(sig2[0]),
	.Out_Imag	(sig2[1])
);

//Stage3
Stage#(.BW(In_BW+2),.N(16))
Stage3(
	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s3),
	.cnt		({cnt[3:0],2'b0}),
	.valid		(valid),
	.In_Real	(sig2[0]),
	.In_Imag	(sig2[1]), 
	
	.Out_Real	(sig3[0]),
	.Out_Imag	(sig3[1])
);

//Stage4
Stage#(.BW(In_BW+3),.N(8)) 
Stage4(
	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s4),
	.cnt		({cnt[2:0],3'b0}),
	.valid		(valid), 
	.In_Real	(sig3[0]),
	.In_Imag	(sig3[1]), 
	
	.Out_Real	(sig4[0]),
	.Out_Imag	(sig4[1])
);
//Stage5
Stage#(.BW(In_BW+4),.N(4)) 
Stage5(
	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s5),
	.cnt		({cnt[1:0],4'b0}),
	.valid		(valid),
	.In_Real	(sig4[0]),
	.In_Imag	(sig4[1]), 
	
	.Out_Real	(sig5[0]),
	.Out_Imag	(sig5[1])
);

//Stage6
Stage#(.BW(In_BW+5),.N(2)) 
Stage6(
	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s6),
	.cnt		({cnt[0],5'b0}),
	.valid		(valid),
	.In_Real	(sig5[0]),
	.In_Imag	(sig5[1]), 

	.Out_Real	(sig6[0]),
	.Out_Imag	(sig6[1])
);

//Stage7
Last_Stage#(.BW(In_BW+6), .N(1))
Stage7(
	.reset_n	(reset_n),
	.clk		(clk),
	.bf_en		(en_s7),
	.valid		(valid),
	.In_Real	(sig6[0]),
	.In_Imag	(sig6[1]), 

	.outreal	(sig7[0]),
	.outimag	(sig7[1])
);

//Output
assign Out_Real = sig7[0][Out_BW-1 : Cut_BW];
assign Out_Imag = sig7[1][Out_BW-1 : Cut_BW];

endmodule
