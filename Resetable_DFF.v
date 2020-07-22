module  Resetable_DFF(
    input clk,
    input reset,
    input D,
    output reg Q
    );
    
    always@(posedge clk or posedge reset)
    begin
     if(reset==1'b1 && D==1'b0)
      Q<=1'b0;
     else if(D==1'b1)
      Q<=1'b1;
    end
endmodule
      
     