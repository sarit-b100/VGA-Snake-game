module Apple(
	input clk,
	input [9:0] blockX[19:0],
	input [9:0] blockY[19:0],
 	input [4:0] snake_length,
	output reg appleX,appleY
);

wire [19:0] overlap;
reg [15:0] H=150,V=41;
reg [4:0] copy_snake_length=5'b00001;

always@(posedge clk)
begin
 if(clk==0 && H<779)begin
  H=H+10;
 end
 else
  H=150;
end
always@(posedge clk)
begin
 if(clk==0 && V<510)begin
  V=V+10;
 end
 else
  V=41;
end 

genvar i;
generate
for(i=0;i<=19;i=i+1)
begin
 assign overlap[i]=(blockX[i]==H && blockY[i]==V)?1'b1:1'b0;
end
endgenerate

always@(posedge clk)
begin
 if(|overlap==1'b0 && (copy_snake_length<snake_length))begin
  appleX=H;appleY=V;
  copy_snake_length=copy_snake_length+1'b1;
 end
end

endmodule
  

