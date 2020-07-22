module top(
	input clk,reset,
 	input UP,DN,RT,LT,
    input A,B,C,
   	output Hsync,
    output Vsync,
    output [3:0] Red,
    output [3:0] Green,
    output [3:0] Blue
);

wire clk_25M;
wire clk_1Hz;
wire enable_V_Counter;
wire [15:0] H_Count_Value;
wire [15:0] V_Count_Value;
reg [4:0] snake_length=5'b00001;
wire snake_body;
reg [19:0] blk=0;
reg [3:0] TEMP=0;

wire CT_deb;
reg [18:0] SE=19'b0;
wire [9:0] r,d,l,u;
wire [9:0] D0[19:0];
wire [9:0] D1[19:0];
wire [9:0] D2[19:0];
wire [9:0] D3[19:0];
wire [9:0] R[19:0];
wire [9:0] L[19:0];
wire [9:0] U[19:0];
wire [9:0] D[19:0];
reg [18:0] GO=0;
wire GAME_OVER,collision;
reg [9:0] appleX=0,appleY=0;

 
/*generating slow_clk for debouncing T=2.5 ms
    reg [26:0]counter=0;
    reg slow_clk;
    always @(posedge clk)
    begin
        counter <= (counter>=249999)?0:counter+1;
        slow_clk <= (counter < 125000)?1'b0:1'b1;
    end*/
    
genvar i;
generate
 for(i=0;i<=18;i=i+1)begin
  DFF instan0(clk_1Hz,reset,D0[i],R[i]);
  DFF instan1(clk_1Hz,reset,D1[i],D[i]);
  DFF instan2(clk_1Hz,reset,D2[i],L[i]);
  DFF instan3(clk_1Hz,reset,D3[i],U[i]);
 end
endgenerate
//put this together with the rest
DFF instan4(clk_1Hz,reset,D0[19],R[19]);
DFF instan5(clk_1Hz,reset,D1[19],D[19]);
DFF instan6(clk_1Hz,reset,D2[19],L[19]);
DFF instan7(clk_1Hz,reset,D3[19],U[19]);

//initialising the position registers
/*generate
 for(i=0;i<=19;i=i+1)begin
  initial begin
   D0[i]=0;D1[i]=0;D2[i]=0;D3[i]=0;
  end
 end
endgenerate*/

  
//connecting the registers for shifting
genvar j;
generate
 for(j=0;j<=18;j=j+1)begin
  assign D0[j]=(SE[j]==1)?R[j+1]:R[j];
  assign D1[j]=(SE[j]==1)?D[j+1]:D[j];
  assign D2[j]=(SE[j]==1)?L[j+1]:L[j];
  assign D3[j]=(SE[j]==1)?U[j+1]:U[j];
 end
endgenerate

//Debounce deb(CT,slow_clk,CT_deb);
clock_divider VGA_Clock_gen(clk,clk_25M);
clock_div instance1(clk,clk_1Hz);
horizontal_counter VGA_Horiz(clk_25M,enable_V_Counter,H_Count_Value);
vertical_counter VGA_Verti(clk_25M,enable_V_Counter,V_Count_Value);

always@(posedge clk)
begin 
 case({RT,LT,UP,DN})
  4'b1000:begin
            TEMP<=4'b1000;
          end
  4'b0100:begin         
            TEMP<=4'b0100;
          end
  4'b0010:begin         
            TEMP<=4'b0010;
          end
  4'b0001:begin         
            TEMP<=4'b0001;
          end   
   endcase      
end


//increasing the length of the snake manually
always@(posedge clk)// or posedge GAME_OVER)
begin
 //if(GAME_OVER==1'b1)begin
  //SE=0;
  //snake_length=5'b00001;
 //end
 if(appleX==blockX[19] && appleY==blockY[19])begin//put <=20 condition!!
  snake_length=snake_length+1'b1;
  SE[20-snake_length]=1'b1;
 end
end

//shifting the instruction registers
/*genvar k;
generate
 for(k=0;k<=snake_length-2;k=k+1)
 begin
  LE[k]=1'b1;
 end
endgenerate*/

//instantiation of various blocks making up the snake

block inst(clk,TEMP[3],TEMP[2],TEMP[1],TEMP[0],r,d,l,u);
assign {D0[19],D1[19],D2[19],D3[19]}={r,d,l,u};


generate 
 for(j=0;j<=19;j=j+1)
 begin
 always@(posedge clk)begin
   blk[j]=((H_Count_Value>L[j] && H_Count_Value<R[j]) && (V_Count_Value>U[j] && V_Count_Value<D[j]));
  end
 end
endgenerate


assign snake_body=|blk;

//checking the snake for self bite or accumulation
/*generate 
 for(j=18;j>=0;j=j-1)
 begin
  always@(posedge clk)
  begin
   if({R[j],L[j],D[j],U[j]}=={R[19],L[19],D[19],U[19]}) begin
    GO[j]=1'b1;
   if(snake_length==5'b00001)
    GO[j]=1'b0;
   end
  end
 end
endgenerate */


//assign collision=(R[19]>780)|(L[19]<140)|(U[19]<40)|(D[19]>510);
//assign GAME_OVER=collision?1'b1:1'b0;

//Apple placement
wire [19:0] overlap;
reg [9:0] H=149,V=40;
wire [9:0] blockX[19:0];
wire [9:0] blockY[19:0];
reg [4:0] copy_snake_length=5'b00000;

generate 
for(i=0;i<=19;i=i+1)
begin
 assign blockX[i]=L[i]+5;
 assign blockY[i]=U[i]+5;
end
endgenerate

always@(posedge clk)
begin
 if(clk==1'b1 && H<779)begin
  H=H+10;
 end
 else
  H=149;
end
always@(posedge clk)
begin
 if(clk==1'b1 && V<510)begin
  V=V+10;
 end
 else
  V=40;
end 

generate
for(i=0;i<=19;i=i+1)
begin
 assign overlap[i]=(blockX[i]==H && blockY[i]==V)?1'b1:1'b0;
end
endgenerate

always@(posedge clk)
begin
 if(|overlap==1'b0 && (copy_snake_length<snake_length))begin
  appleX=H;
  appleY=V;
  copy_snake_length=copy_snake_length+1'b1;
 end
end


//outputs
assign Hsync = (H_Count_Value < 96) ? 1'b1:1'b0;
assign Vsync = (V_Count_Value < 2) ? 1'b1:1'b0;

//colors
assign Red = (snake_body)? 4'hF:4'h0;
assign Green = (H_Count_Value < appleX+5 && H_Count_Value > appleX-5 && V_Count_Value < appleY+5 && V_Count_Value > appleY-5)? 4'hF:4'h0;
assign Blue = (C==1'b1 && H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 34)? 4'hF:4'h0;


endmodule



