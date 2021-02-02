`timescale 1ns / 1ps
`include "Types.sv"

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
    wire jalr, branch, jal, pc_source;
    assign pc_write = 1'b1;
    assign mem_read1 = 1'b1;
    
    Memory #(.MEM_FILE(MEM_FILE)) memory(
        .MEM_CLK(CLK),
        .MEM_RDEN1(mem_read1)
    );

    RegFile regfile(
        .clk(CLK)
    );

    IFStage if_stage(
        .clk(CLK),
        .reset(RESET),
        .jalr(jalr),
        .branch(branch),
        .jal(jal),
        .pc_source(pc_source),
        .pc_write(pc_write)
    );
    IFID_t if_result;
    assign if_result = '{
        pc: if_stage.pc,
        ir: memory.MEM_DOUT1
    };
    
    PipelineRegister #(.SIZE($bits(IFID_t))) if_id_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(if_result)
    );
        
    IDStage id_stage(
        .prev(if_id_reg.out_data),
        .adr1(regfile.adr1),
        .adr2(regfile.adr2),
        .rs1(regfile.rs1),
        .rs2(regfile.rs2)
    );
    
    PipelineRegister #(.SIZE($bits(IDEX_t))) id_ex_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(id_stage.result)
    );
        
    EXStage ex_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(id_ex_reg.out_data)
    );
    
    PipelineRegister #(.SIZE($bits(EXMEM_t))) ex_mem_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(ex_stage.result) 
    );
        
    MEMStage mem_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(ex_mem_reg.out_data)
    );
    
    PipelineRegister #(.SIZE($bits(MEMWB_t))) mem_wb_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(mem_stage.result)    
    );
        
    WBStage wb_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(mem_wb_reg.out_data)
    );
    
endmodule
