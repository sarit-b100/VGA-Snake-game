`timescale 1ns / 1ps


module clock_divider(
    input masCLK,
    output reg CLK=0
    );
    //generating 25MHz clock
    reg [1:0] tictoc2=0;
    always@(posedge masCLK)
    begin
     if(tictoc2<2)
      tictoc2<=tictoc2+1'b1;
     else
     begin
      tictoc2<=0;
      CLK<=~CLK;
     end
    end
endmodule
