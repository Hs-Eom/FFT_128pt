`timescale 1ns/1ps
`define p 12
module tb_Top_FFT;

reg reset_n,clk;


reg [15:0] input_re[383:0];
reg [15:0] input_im[383:0];

reg [15:0] output_re[(1+384+128+140):0];
reg [15:0] output_im[(1+384+128+140):0];
 
wire [15:0] inReal,inImag;
wire [15:0] outReal,outImag;

integer clkcnt;

reg start;

//instantiation
Top_FFT
inst_top(
    .clk        (clk),
    .reset_n    (reset_n),
    .valid      (1'b1),
    .start      (start),
    .In_Real    (inReal),
    .In_Imag    (inImag),

    .Out_Real   (outReal),
    .Out_Imag   (outImag)
);

//clk 10ns
always begin
  #(`p/2)  clk = !clk;
end

//clkcnt is variable in input_re,im
always@(negedge clk) begin
  clkcnt = clkcnt +1;
end


initial begin
  clk  = 0;
  reset_n = 0;
  clkcnt=-4;
  start = 0;
  $readmemb("/home/ehs/Src/portfolio/binary_in_real.txt", input_re); //modify to your path
  $readmemb("/home/ehs/Src/portfolio/binary_in_imag.txt", input_im);

  #(`p) start = 1'b1; 
  #(`p/2+1) reset_n = 1;
end

assign inReal = clkcnt <= -2 ? 0: 
                              clkcnt > 382 ? 0: input_re[clkcnt+1];
assign inImag = clkcnt <= -2 ? 0: 
                                  clkcnt>382? 0: input_im[clkcnt+1];

always @ (posedge clk) begin
  output_re[clkcnt+1] <= outReal;
  output_im[clkcnt+1] <= outImag;
end


integer dumpfile, i;
initial begin


  #((1+384+128+140)*`p +1) dumpfile = $fopen("binary_out_real.txt","w");
  for(i = 0; i<1+384+128+140;i=i+1)begin
  $fwrite(dumpfile,"%b\n",output_re[i]);
  end
  $fclose(dumpfile);
  
    dumpfile = $fopen("binary_out_imag.txt","w");
    for(i = 0; i<1+384+128+140;i=i+1)begin
    $fwrite(dumpfile,"%b\n",output_im[i]);
    end
    $fclose(dumpfile);

  $stop;
end

//Latency
reg [31:0] latency;
reg [15:0] prev_real;
reg [15:0] prev_imag;

always@(posedge clk) begin
    if(!reset_n) begin
        prev_imag <= 0;
        prev_real <= 0;
    end
    else begin
        prev_real <= inReal;
        prev_imag <= inImag;
    end
end

always@(posedge clk) begin
    if(!reset_n) begin
        latency <= -1;
    end
    else if((prev_real != inReal) || (prev_imag != inImag)) begin
        latency <= latency + 1;
    end
end

endmodule
