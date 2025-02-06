module Shift_Reg
#(
	parameter BW= 16,
	parameter N = 64
)
(
	input wire 				reset_n,
	input wire 				clk,
	input wire [BW:0]		In_Data,
	input wire 				valid,
	output wire [BW:0]	Out_Data
);
//ila
// ila_2
// Sr_ILA(
//     .clk    (clk),
//     .probe0 (valid),
//     .probe1 (In_Data),
//     .probe2 (Out_Data),
//     .probe3 (sr[0]),
//     .probe4 (sr[1]),
//     .probe5 (sr[2]),
//     .probe6 (sr[62]),
//     .probe7 (sr[63])
// );


//Shift Register declare
reg [BW:0] sr[N-1:0];
integer i;

// 1.Data comes into the Shift Register
always@(posedge clk) begin
    if(!reset_n) begin
      sr[0] <= 0;
	end
    else if (valid) begin
      sr[0] <= In_Data;
	end
end

// 2. Data is shifted to the left register whenever clocking
always@(posedge clk) begin
	if(!reset_n) begin
		for(i=1; i<N; i=i+1)
			sr[i] <= 0;
	end
	else if (valid) begin
		for(i=1; i<N; i=i+1)
			sr[i] <= sr[i-1];			
	end
end



//output
assign Out_Data = sr[N-1];

endmodule