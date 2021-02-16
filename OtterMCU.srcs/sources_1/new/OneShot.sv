`timescale 1ns / 1ps

module OneShot(
    input clk,
    input sig,
    input reset = 0,
    output out
    );
    reg last = 0;
    
    assign out = last != sig;
    
    always @(posedge clk) begin
        last <= reset | sig;
    end
    
endmodule
