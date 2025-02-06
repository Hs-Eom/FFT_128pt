`timescale 1ns/1ns

module axi_slave_FFT_f_ps#(
     parameter WIDTH_SID=15,
	parameter WIDTH_AD=14,   // address width
     parameter WIDTH_DA=32,   // data width
     parameter WIDTH_DS=4     // data strobe width
)
(
     input  wire                 S_AXI_ACLK,
     input  wire                 S_AXI_ARESETN,
     
     //AW Channel
     input  wire [WIDTH_SID-1:0] S_AXI_AWID,
     input  wire [WIDTH_AD-1:0]  S_AXI_AWADDR,
     input  wire [7:0]          S_AXI_AWLEN,
     //input  wire                 S_AXI_AWLOCK,
     input  wire [2:0]          S_AXI_AWSIZE,
     input  wire [1:0]          S_AXI_AWBURST,	
     input  wire                 S_AXI_AWVALID,
     output wire                 S_AXI_AWREADY,
     
     //Write Channel
     input  wire [WIDTH_SID-1:0] S_AXI_WID,
     input  wire [WIDTH_DA-1:0]  S_AXI_WDATA,
     input  wire [WIDTH_DS-1:0]  S_AXI_WSTRB,
     input  wire                 S_AXI_WLAST,
     input  wire                 S_AXI_WVALID,
     output wire                 S_AXI_WREADY,
     
     //Response Channel
     output reg  [WIDTH_SID-1:0] S_AXI_BID,
     output wire [1:0]          S_AXI_BRESP,
     output reg                  S_AXI_BVALID,
     input  wire                 S_AXI_BREADY,
     
     //AR Channel
     input  wire [WIDTH_SID-1:0] S_AXI_ARID,
     input  wire [WIDTH_AD-1:0]  S_AXI_ARADDR,
     input  wire [7:0]          S_AXI_ARLEN,
     //input  wire                 S_AXI_ARLOCK,
     input  wire [2:0]          S_AXI_ARSIZE,
     input  wire [1:0]          S_AXI_ARBURST,	
     input  wire                 S_AXI_ARVALID,
     output wire                 S_AXI_ARREADY,
     
     //R Channel
     output wire [WIDTH_SID-1:0] S_AXI_RID,
     output wire [WIDTH_DA-1:0]  S_AXI_RDATA,
     output wire [1:0]          S_AXI_RRESP,
     output wire                 S_AXI_RLAST,
     output wire                 S_AXI_RVALID,
     input  wire                 S_AXI_RREADY
);

//FFT(IP)
wire start_FFT = !(S_AXI_WDATA == 32'h7FFFFFFF);

Top_FFT#(.In_BW(16), .Out_BW(23), .Cut_BW(7))
inst_FFT(
	.reset_n(start_FFT),
	.clk(clk),
	.start(start_FFT),
	.valid(S_AXI_WVALID && S_AXI_WREADY),
	.In_Real(S_AXI_WDATA[31:16]),
	.In_Imag(S_AXI_WDATA[15:0]),
	
    .Out_Real(S_AXI_RDATA[31:16]),
	.Out_Imag(S_AXI_RDATA[15:0])
);

endmodule