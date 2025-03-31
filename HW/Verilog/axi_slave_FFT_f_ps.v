`timescale 1ns/1ns

module axi_slave_FFT_f_ps(
   // Slave(FFT Input)
   input                           s_axis_aclk,
   input                           s_axis_aresetn,
   input                           s_axis_tvalid,
   output                          s_axis_tready,
   input signed [32-1:0]   		  s_axis_tdata,
   input                           s_axis_tlast,
   input        [32/8-1:0] 		  s_axis_tkeep,

    // Master(FFT Output)
   input                           m_axis_aclk,
   input                           m_axis_aresetn,
   output                          m_axis_tvalid,
   input                           m_axis_tready,
   output signed [32-1:0]   		  m_axis_tdata,
   output                          m_axis_tlast,
   output        [32/8-1:0] 		  m_axis_tkeep
);




/////////////////////////////////////////
/////////// IP Description //////////////


wire start_FFT = !(s_axis_tdata==32'h7FFFFFFF); 
wire valid = s_axis_tvalid && s_axis_tready;
Top_FFT#(.In_BW(16), .Out_BW(23), .Cut_BW(7)) 
inst_FFT(
	.reset_n  (s_axis_aresetn), 
	.clk      (s_axi_aclk),
	.start    (start_FFT), 
	.valid    (valid),
	.In_Real  (s_axis_tdata[31:16]),
	.In_Imag  (s_axis_tdata[15:0]),
	.Out_Real (m_axis_tdata[31:16]),
	.Out_Imag (m_axis_tdata[15:0])
);

assign m_axis_tvalid = s_axis_tvalid;
assign s_axis_tready = m_axis_tready;
assign m_axis_tlast  = s_axis_tlast;
assign m_axis_tkeep  = s_axis_tkeep;

endmodule
