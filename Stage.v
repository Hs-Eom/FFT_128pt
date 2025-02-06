module Stage#(
    parameter BW = 16,
    parameter N = 64
)
(
    input wire clk,
    input wire reset_n,
    input wire valid,
    input wire bf_en,
    input wire [5:0] cnt,
    input wire [BW-1:0] In_Real,
    input wire [BW-1:0] In_Imag,

    output wire [BW:0] Out_Real,
    output wire [BW:0] Out_Imag
);



//declare wire [0]:Real, [1]:Imag

wire [BW:0] Sr_Out[1:0];

wire [BW:0] mux1[1:0];
wire [BW:0] mux0[1:0];

wire [BW:0] bf_P[1:0];
wire [BW:0] bf_M[1:0];

wire [BW:0] Mult_out[1:0];

//Register Real, Imag
reg [BW-1:0] r_Real;
reg [BW-1:0] r_Imag;

always @(posedge clk ) begin
    if(!reset_n) begin
        r_Real <= 0;
        r_Imag <= 0;
    end
    else if(valid) begin
        r_Real <= In_Real;
        r_Imag <= In_Imag;
    end
end

//Butterfly Calc
BF_Calc#(.BW(BW))
bf(
    .In_Real    (r_Real),
    .In_Imag    (r_Imag),
    .Sr_Real    ({Sr_Out[0][BW],Sr_Out[0][BW-2:0]}),
    .Sr_Imag    ({Sr_Out[1][BW],Sr_Out[1][BW-2:0]}),
    
    .P_Real     (bf_P[0]),
    .P_Imag     (bf_P[1]),
    .M_Real     (bf_M[0]),
    .M_Imag     (bf_M[1])
);

//Shift Register
Shift_Reg#(.BW(BW), .N(N))
Sr_Real(
    .clk        (clk),
    .reset_n    (reset_n),
    .valid      (valid),
    .In_Data     (mux1[0]),
    
    .Out_Data   (Sr_Out[0])
);

Shift_Reg#(.BW(BW), .N(N))
Sr_Imag(
    .clk        (clk),
    .reset_n    (reset_n),
    .valid      (valid),
    .In_Data     (mux1[1]),
    
    .Out_Data   (Sr_Out[1])
);

//Mux with BF
assign mux0[0] = bf_en ? bf_P[0] : Sr_Out[0];
assign mux0[1] = bf_en ? bf_P[1] : Sr_Out[1];

assign mux1[0] = bf_en ? bf_M[0] : {r_Real[BW-1],r_Real};
assign mux1[1] = bf_en ? bf_M[1] : {r_Imag[BW-1],r_Imag};

//Multiplyer with Wk(Twiddle Factors)
Mult#(.BW(BW))
inst_Mult(
    .cnt        (cnt),
    .In_Real    (mux0[0]),
    .In_Imag    (mux0[1]),

    .Out_Real   (Mult_out[0]),
    .Out_Imag   (Mult_out[1])
);

//Output
assign Out_Real = bf_en ? mux0[0] : Mult_out[0];
assign Out_Imag = bf_en ? mux0[1] : Mult_out[1];

////ILA
//ila_1 inst_ila(
//    .clk    (clk),
//    .probe0 (r_Real),
//    .probe1 (r_Imag),
//    .probe2 (Sr_Out[0]),
//    .probe3 (Sr_Out[1]),
//    .probe4 (bf_P[0]),
//    .probe5 (bf_P[1]),
//    .probe6 (bf_M[0]),
//    .probe7 (bf_M[1]),
//    .probe8 (mux0[0]),
//    .probe9 (mux0[1]),
//    .probe10 (mux1[0]),
//    .probe11 (mux1[1]),
//    .probe12 (Mult_out[0]),
//    .probe13 (Mult_out[1]),
//    .probe14 (bf_en)
//);

endmodule