`timescale 10ns / 1ns

module Benchmark();
    reg RST; 
    reg intr; 
    reg clk; 
    reg [31:0] iobus_in; 
    wire [31:0] iobus_addr; 
    wire [31:0] iobus_out; 
    wire iobus_wr; 

    OTTER_MCU #(.MEM_FILE("test_all.mem"))  my_otter(
     .RST         (RST),
     .intr        (intr),
     .clk         (clk),
     .iobus_in    (iobus_in),
     .iobus_out   (iobus_out), 
     .iobus_addr  (iobus_addr), 
     .iobus_wr    (iobus_wr)
    );
     
    //- Generate periodic clock signal    
    initial begin       
        clk = 0;       
        forever #1 clk = ~clk;
    end
        
    logic [63:0] start;
     
    initial begin           
        RST=1;
        intr=0;
        iobus_in = 32'h0;
    
        #40

        RST = 0;
        start = $time;
        $display("Started", start);
    end
endmodule
