`timescale 1ns / 1ps
import Types::*;

module OTTER_MCU #(parameter MEM_FILE="otter_memory.mem")
(
    input branch_predictor_t bp_selection = bp_random,
    input CLK,
    input INTR,
    input RESET,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR 
);
    logic [31:0] jalr, branch, jal;
    
    logic [31:0] if_pc, mem_dout1, wb_dout;
    logic flush_ifid, flush_idex;
    MEMWB_t mem_result;
    EXMEM_t mem_input;
    Memory #(.MEM_FILE(MEM_FILE)) mem(
        .MEM_CLK(CLK),
        .MEM_RDEN1(1'b1),
        .MEM_ADDR1(if_pc[15:2]),
        .flush_dout1(flush_ifid),
        .MEM_DOUT1(mem_dout1),
        
        .MEM_RDEN2(mem_input.mem.read),
        .MEM_ADDR2(mem_input.alu_result),
        .MEM_DOUT2(wb_dout),
        
        .MEM_WE2(mem_input.mem.write),
        .MEM_SIZE(mem_input.mem.size),
        .MEM_SIGN(mem_input.mem.sign),
        .MEM_DIN2(mem_input.mem.rs2),
        
        .IO_IN(IOBUS_IN),
        .IO_WR(IOBUS_WR)
    );
    assign IOBUS_OUT = mem_input.mem.rs2;
    assign IOBUS_ADDR = mem_input.alu_result;
    
    function void load_memory(input string file);
        mem.load_memory(file);
    endfunction
    
    logic [31:0] wb_wd, id_rs1, id_rs2;
    logic [4:0] id_adr1, id_adr2, wb_wa; 
    logic wb_we;
    RegFile regfile(
        .clk(CLK),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .adr1(id_adr1),
        .adr2(id_adr2),
        .wd(wb_wd),
        .wa(wb_wa),
        .en(wb_we)
    );

    logic stall, idex_mem_read;
    logic [4:0] idex_wb_wa;
    logic [31:0] id_ir;
    HazardDetection hazard(
        .clk(CLK),
        .idex_mem_read(idex_mem_read),
        .idex_wb_wa(idex_wb_wa),
        .ifid_adr1(id_adr1),
        .ifid_adr2(id_adr2),
        .ir_fetched(mem_dout1),
        .ir(id_ir),
        .stall(stall)
    );
    
    logic [31:0] id_target, ex_pc, ex_target, pc_d;
    br_predict_t id_branch_status;
    br_certain_t ex_branch_status;
    
    IBranchControlUnit ibcu();
    assign flush_ifid = ibcu.flush_ifid;
    assign flush_idex = ibcu.flush_idex;
    BranchControlUnit bcu(
        .clk(CLK),
        .reset(reset),
        .iface(ibcu.BCU)
    );
    BranchPredictor ibpred(
        .clk(CLK),
        .reset(reset)
    );
    MultiplexedBranchPredictor bpred(
        .bp(ibpred.Predictor),
        .selection(bp_selection)
    );
    
    //////// IF ////////
    
    IFStage if_stage(
        .clk(CLK),
        .reset(RESET),
        .bcu(ibcu.IF),
        .pc_write(!stall),
        .pc(if_pc)
    );
    
    //////// ID ////////

    logic [31:0] id_pc;
    PipelineRegister #(.SIZE(32)) if_id_reg(
        .clk(CLK),
        .flush(RESET | flush_ifid),
        .hold(stall),
        .in_data(if_pc),
        .out_data(id_pc)
    );
    
    IDEX_t id_out;
    IDStage id_stage(
        .pc(id_pc),
        .ir(id_ir),
        .adr1(id_adr1),
        .adr2(id_adr2),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .bcu(ibcu.ID),
        .predictor(ibpred.ID),
        .result(id_out)
    );

    //////// EX ////////
    
    IDEX_t ex_in;
    PipelineRegister #(.SIZE($bits(IDEX_t))) id_ex_reg(
        .clk(CLK),
        .flush(RESET | stall | flush_idex),
        .in_data(id_out),
        .out_data(ex_in)
    );
    
    EXMEM_t ex_out;
    EXStage ex_stage(
        .clk(CLK),
        .reset(RESET),
        .prev(ex_in),
        
        .idex_mem_read(idex_mem_read),
        .idex_wb_wa(idex_wb_wa),
        
        .exmem_wa(mem_input.wb.wa),
        .exmem_data(mem_input.alu_result),
        .exmem_we(mem_input.wb.rf_wr_en & mem_input.wb.rf_wr_sel == regwr_ALU),
        
        .memwb_wa(wb_wa),
        .memwb_data(wb_wd),
        .memwb_we(wb_we),
        
        .bcu(ibcu.EX),
        .predictor(ibpred.EX),
        .result(ex_out)
    );
    
    //////// MEM ////////
    
    PipelineRegister #(.SIZE($bits(EXMEM_t))) ex_mem_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(ex_out),
        .out_data(mem_input)
    );
    
    assign mem_result.pc = mem_input.pc;
    assign mem_result.alu_result = mem_input.alu_result;
    assign mem_result.wb = mem_input.wb;
    
    //////// WB ////////
    
    MEMWB_t wb_in;
    PipelineRegister #(.SIZE($bits(MEMWB_t))) mem_wb_reg(
        .clk(CLK),
        .flush(RESET),
        .in_data(mem_result),
        .out_data(wb_in)    
    );
    
    WBStage wb_stage(
        .prev(wb_in),
        .mem_dout(wb_dout),
        .wd(wb_wd),
        .wa(wb_wa),
        .we(wb_we)
    );
    
endmodule
