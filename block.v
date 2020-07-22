module block(
    input clk,
	input RT,LT,UP,DN,
	output reg [9:0] R=164,D=55,L=154,U=45
);

wire Move_Rt,Move_Lt,Move_Up,Move_Dn;
wire R1,R2,R3,R4;
wire clk_4Hz;


/*always@(*)
begin 
 case(Instr)
  2'b00:{RT,LT,UP,DN}<=4'b1000;
  2'b01:{RT,LT,UP,DN}<=4'b0100;
  2'b10:{RT,LT,UP,DN}<=4'b0010;
  2'b11:{RT,LT,UP,DN}<=4'b0001;         
 endcase      
end*/

assign R1=(Move_Lt || Move_Up || Move_Dn);
assign R2=(Move_Rt || Move_Up || Move_Dn);
assign R3=(Move_Rt || Move_Lt || Move_Dn);
assign R4=(Move_Rt || Move_Lt || Move_Up);

clock_div cd(clk,clk_4Hz);
Resetable_DFF D1(clk,R1,RT,Move_Rt);
Resetable_DFF D2(clk,R2,LT,Move_Lt);
Resetable_DFF D3(clk,R3,UP,Move_Up);
Resetable_DFF D4(clk,R4,DN,Move_Dn);

always@(posedge clk_4Hz)
begin
 case({Move_Rt,Move_Dn,Move_Lt,Move_Up})
 4'b1000:begin
    if(R<784)begin
     R<=R+10;L<=L+10;end
    end
 4'b0100:begin
    if(D<515)begin
    D<=D+10;U<=U+10;end
    end
 4'b0010:begin
    if(L>144)begin
     L<=L-10;R<=R-10;end
    end
 4'b0001:begin
    if(U>35)begin
     U<=U-10;D<=D-10;end
    end   
 endcase
end
endmodule