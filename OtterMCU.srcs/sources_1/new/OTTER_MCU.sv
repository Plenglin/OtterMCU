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
    
    PipelineRegister #(.SIZE($bits(IFID_t))) if_id_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(if_stage.result)       
    );
        
    IDStage id_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(if_id_reg.out_data),
        .regfile(regfile)
    );
    
    PipelineRegister #(.SIZE($bits(IDEX_t))) id_ex_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(id_stage.result)
    );
        
    EXStage ex_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(if_stage.result)
    );
    
    PipelineRegister #(.SIZE($bits(EXMEM_t))) ex_mem_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(ex_stage.result) 
    );
        
    MEMStage mem_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(ex_mem_reg.out_data),
        .mem(memory)
    );
    
    PipelineRegister #(.SIZE($bits(MEMWB_t))) mem_wb_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(mem_stage.result)    
    );
        
    WBStage wb_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(mem_stage.result),
        .regfile(regfile)
    );
    
endmodule
