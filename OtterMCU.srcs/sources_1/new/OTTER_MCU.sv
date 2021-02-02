`timescale 1ns / 1ps

module OTTER_MCU #(parameter MEM_FILE="otter_memory.mem")
(
    input CLK,
    input INTR,
    input RESET,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR 
);
    wire jalr, branch, jal, pcSource;
    assign pc_write = 1'b1;
    assign mem_read1 = 1'b1;
    
    Memory #(.MEM_FILE(MEM_FILE)) memory(.MEM_RDEN1(mem_read1));
    RegFile regfile();
              
    IFStage if_stage(
        .clk(CLK),
        .reset(RESET),
        .mem(memory),
        .pc_write(pc_write)
    );
        
    IDStage id_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(if_stage.result),
        .regfile(regfile)
    );
        
    EXStage ex_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(if_stage.result)
    );
        
    MEMStage mem_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(ex_stage.result),
        .mem(memory)
    );
        
    WBStage wb_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(mem_stage.result),
        .regfile(regfile)
    );
    
endmodule
