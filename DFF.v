module DFF(
	input clk,
	input reset,
	input [9:0] D,
	output reg [9:0] Q
);
 
always@(negedge clk or negedge reset)
begin
 if(reset==1'b0)
  Q<=10'b0;
 else
  Q<=D;
end
endmodule