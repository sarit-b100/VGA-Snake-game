`timescale 1ns / 1ps


module clock_div(
    input masCLK,
    output reg CLK=0
    );
    //generating 1Hz clock
    reg [29:0] tictoc2=0;
    always@(posedge masCLK)
    begin
     if(tictoc2<50000000)//change it to 50,000,000 for a 1Hz clock
      tictoc2<=tictoc2+1'b1;
     else
     begin
      tictoc2<=0;
      CLK<=~CLK;
     end
    end
endmodule