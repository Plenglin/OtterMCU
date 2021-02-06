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
    logic [31:0] jalr, branch, jal;
    logic [1:0] pc_source = 0;
    assign pc_write = 1'b1;
    assign mem_read1 = 1'b1;
    
    Memory #(.MEM_FILE(MEM_FILE)) mem(
        .MEM_CLK(CLK),
        .MEM_RDEN1(mem_read1),
        .MEM_RDEN2(0)
    );

    RegFile regfile(
        .clk(CLK)
    );

    //////// IF ////////
    
    IFStage if_stage(
        .clk(CLK),
        .reset(RESET),
        .jalr(jalr),
        .branch(branch),
        .jal(jal),
        .pc_source(pc_source),
        .pc_write(pc_write),
        .pc(mem.MEM_ADDR1)
    );
    
    //////// ID ////////

    PipelineRegister #(.SIZE($bits(IFID_t))) if_id_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(if_stage.pc)
    );
    
    IFID_t id_in;
    assign id_in = if_id_reg.out_data;
    IDEX_t id_out;
    IDStage id_stage(
        .prev(id_in),
        .ir(mem.MEM_DOUT1),
        .adr1(regfile.adr1),
        .adr2(regfile.adr2),
        .rs1(regfile.rs1),
        .rs2(regfile.rs2),
        .result(id_out)
    );

    //////// EX ////////
    
    PipelineRegister #(.SIZE($bits(IDEX_t))) id_ex_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(id_out)
    );
    
    EXStage ex_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(id_ex_reg.out_data)
    );
    
    //////// MEM ////////
    PipelineRegister #(.SIZE($bits(EXMEM_t))) ex_mem_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(ex_stage.result) 
    );
    
    EXMEM_t mem_input;
    assign mem_input = ex_mem_reg.out_data;
    
    assign mem.MEM_WE2 = mem_input.mem.write;
    assign mem.MEM_RDEN2 = mem_input.mem.read;
    assign mem.MEM_SIZE = mem_input.mem.size;
    assign mem.MEM_DIN2 = mem_input.mem.rs2;
    assign mem.MEM_ADDR2 = mem_input.alu_result;
    
    MEMWB_t mem_result;
    assign mem_result = '{
        pc: mem_input.pc,
        alu_result: mem_input.alu_result,
        dout: mem.MEM_DOUT2,
        wb: mem_input.wb
    };
    
    //////// WB ////////
/*
    
    PipelineRegister #(.SIZE($bits(MEMWB_t))) mem_wb_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(mem_result)    
    );
    
    WBStage wb_stage(
        .prev(mem_wb_reg.out_data),
        .mem_dout(mem.MEM_DOUT2),
        .wd(regfile.wd),
        .wa(regfile.wa),
        .we(regfile.en)
    );*/
    
endmodule
