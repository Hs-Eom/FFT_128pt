
module Last_Stage#(
	parameter BW = 16,
	parameter N = 1
)
(
	input wire 			reset_n,
	input wire 			clk,
	input wire 			bf_en,
	input wire 			valid, 
	input wire [BW-1:0]	In_Real,
	input wire [BW-1:0]	In_Imag,
	
	output wire [BW:0] outreal,
	output wire [BW:0] outimag
);
//ILA
// ila_0 inst_ila(
//     .clk    (clk),
//     .probe0 (r_Real),
//     .probe1 (r_Imag),
//     .probe2 (Sr_out[0]),
//     .probe3 (Sr_out[1]),
//     .probe4 (bf_P[0]),
//     .probe5 (bf_P[1]),
//     .probe6 (bf_M[0]),
//     .probe7 (bf_M[1]),
//     .probe8 (mux0[0]),
//     .probe9 (mux0[1]),
//     .probe10 (mux1[0]),
//     .probe11 (mux1[1]),
//     .probe12 (bf_en),
//     .probe13 (outreal),
//     .probe14 (outimag)
// );

//declare wire [0]:Real, [1]:Imag
reg [BW-1:0] r_Real;
reg [BW-1:0] r_Imag;

wire [BW:0] bf_P[1:0];
wire [BW:0] bf_M[1:0];

reg  [BW:0] Sr_out[1:0];

wire [BW:0] mux0[1:0];
wire [BW:0] mux1[1:0];

always @(posedge clk) begin
    if(!reset_n) begin
        r_Real <=0;
        r_Imag <=0;
    end
    else if(valid) begin
        r_Real <= In_Real;
        r_Imag <= In_Imag;
    end
end


//1bit Shift register = normal register
always@(posedge clk) begin
	if(!reset_n) begin
	  Sr_out[0] <= 0;
      	  Sr_out[1] <= 0;
	end
	else if(valid) begin        
      Sr_out[0] <= mux1[0];
      Sr_out[1] <= mux1[1];
	end
end

//Butterfly Calc
BF_Calc#(.BW(BW))
bf0(
    .In_Real(r_Real),
    .In_Imag(r_Imag),
    .Sr_Real({Sr_out[0][BW],Sr_out[0][BW-2:0]}),
    .Sr_Imag({Sr_out[1][BW],Sr_out[1][BW-2:0]}),
    
    .P_Real(bf_P[0]),
    .P_Imag(bf_P[1]),
    .M_Real(bf_M[0]),  
    .M_Imag(bf_M[1])
);

//Mux with BF
assign mux0[0] = bf_en? bf_P[0] : Sr_out[0];
assign mux0[1] = bf_en? bf_P[1] : Sr_out[1];

assign mux1[0] = bf_en? bf_M[0] : {r_Real[BW-1],r_Real};
assign mux1[1] = bf_en? bf_M[1] : {r_Imag[BW-1],r_Imag};

//Output
assign outreal = mux0[0];
assign outimag = mux0[1];

endmodule