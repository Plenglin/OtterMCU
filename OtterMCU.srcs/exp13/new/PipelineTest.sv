`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2021 10:46:48 AM
// Design Name: 
// Module Name: PipelineTest
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


module PipelineTest();
    reg RST; 
    reg intr; 
    reg clk; 
    reg [31:0] iobus_in; 
    wire [31:0] iobus_addr; 
    wire [31:0] iobus_out; 
    wire iobus_wr; 

    OTTER_MCU #(.MEM_FILE("test_all_no_hazard.mem"))  my_otter(
     .RESET         (RST),
     .INTR        (intr),
     .CLK         (clk),
     .IOBUS_IN    (0),
     .IOBUS_OUT   (iobus_out), 
     .IOBUS_ADDR  (iobus_addr), 
     .IOBUS_WR    (iobus_wr)
    );
     
    //- Generate periodic clock signal    
    initial begin       
        clk = 0;       
        forever #1 clk = ~clk;
    end
        
    logic [63:0] start;
     
    initial begin           
        RST=1;
    
        #4

        RST = 0;
        start = $time;
        $display("Started", start);
    end
endmodule
