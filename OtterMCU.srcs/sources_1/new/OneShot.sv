`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2021 12:10:27 AM
// Design Name: 
// Module Name: OneShot
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
