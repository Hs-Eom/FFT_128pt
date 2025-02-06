module BF_Calc#(
    parameter BW = 16
)
(
    input wire signed [BW-1:0] In_Real,
    input wire signed [BW-1:0] In_Imag,
    input wire signed [BW-1:0] Sr_Real,
    input wire signed [BW-1:0] Sr_Imag,

    output wire signed [BW:0]  P_Real,
    output wire signed [BW:0]  P_Imag,
    output wire signed [BW:0]  M_Real,
    output wire signed [BW:0]  M_Imag
);

assign P_Real = Sr_Real + In_Real;
assign P_Imag = Sr_Imag + In_Imag;
assign M_Real = Sr_Real - In_Real;
assign M_Imag = Sr_Imag - In_Imag;

endmodule