import Types::*;

module EXStage(
    input clk,
    input reset,
    input IDEX_t prev,
    
    input [4:0] exmem_wa,
    input [31:0] exmem_data,
    input exmem_we,
    
    input [4:0] memwb_wa,
    input [31:0] memwb_data,
    input memwb_we,
    
    output EXMEM_t result,
    output pcsrc_t pc_source,
    output [31:0] jal,
    output [31:0] jalr,
    output [31:0] branch
);
    logic [31:0] alu_a;
    ForwardingUnit fu_a(
        .idex_adr(prev.alu_a_adr),
        .idex_data(prev.alu_a),
        
        .exmem_wa(exmem_wa),
        .exmem_data(exmem_data),
        .exmem_we(exmem_we),
        
        .memwb_wa(memwb_wa),
        .memwb_data(memwb_data),
        .memwb_we(memwb_we),
        
        .alu_arg(alu_a)
    );
    
    logic [31:0] alu_b;
    ForwardingUnit fu_b(
        .idex_adr(prev.alu_b_adr),
        .idex_data(prev.alu_b),
        
        .exmem_wa(exmem_wa),
        .exmem_data(exmem_data),
        .exmem_we(exmem_we),
        
        .memwb_wa(memwb_wa),
        .memwb_data(memwb_data),
        .memwb_we(memwb_we),
        
        .alu_arg(alu_b)
    );
    
    ALU alu(
        .srcA(alu_a), 
        .srcB(alu_b), 
        .alu_fun(prev.alu_fun),
        .result(result.alu_result)
    );
    
    BranchCondGen bcg(
        .rs1(alu_a),
        .rs2(alu_b),
        .opcode(prev.opcode),
        .func3(prev.func3),
        .pcSource(pc_source)
    );

    BranchAddrGen bag(
        .pc(prev.pc),
        .rs(alu_a),
        .b_type_imm(prev.b_imm),
        .i_type_imm(prev.i_imm),
        .j_type_imm(prev.j_imm),
        .jal(jal),
        .jalr(jalr),
        .branch(branch)
    );
    
    assign result.pc = prev.pc;
    assign result.mem = prev.mem;
    assign result.wb = prev.wb;
endmodule