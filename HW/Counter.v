module Counter#(
    parameter N = 128,
    parameter num = $clog2(N)
)
(
    input wire clk,
    input wire reset_n,
    input wire valid,
    input wire start,

    output reg [num-1:0] cnt //for counting 128(Max)
);

always @(posedge clk) begin
    if(!reset_n) begin
        cnt <= 7'b1111111;
    end
    else if((!start) && valid) begin
        cnt <= 7'b1111111;
    end
    else if(valid) begin
        cnt <= cnt + 1;
    end
end  

endmodule