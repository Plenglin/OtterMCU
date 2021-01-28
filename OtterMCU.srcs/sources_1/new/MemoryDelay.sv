`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2021 10:28:33 PM
// Design Name: 
// Module Name: MemoryDelay
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


module MemoryDelay#(LATENCY=10)(
    input access,
    input clk,
    output ready
);
    reg [7:0] counter = 0;
    assign _ready = counter == 0;
    
    OneShot access_os(.clk(clk), .sig(access), .reset(ready_os.out));
    OneShot ready_os(.clk(clk), .sig(_ready));
    
    assign ready = LATENCY < 3 ? 1 : ready_os.out;
    
    always @(posedge clk) begin
        if (access_os.out)
            counter <= LATENCY - 2;
        else if (!_ready)
            counter <= counter - 1;
    end
    
endmodule
