`include "Types.sv"

module EXStage(
    input clk,
    input reset,
    input IDEX_t prev,
    output EXMEM_t result,
    output pcsrc_t pc_source,
    output [31:0] jal,
    output [31:0] jalr,
    output [31:0] branch
);
    ALU alu(
        .srcA(prev.alu_a), 
        .srcB(prev.alu_b), 
        .alu_fun(prev.alu_fun),
        .result(result.alu_result)
    );
    
    BranchCondGen bcg(
        .rs1(prev.alu_a),
        .rs2(prev.alu_b),
        .opcode(prev.opcode),
        .func3(prev.func3),
        .pcSource(pc_source)
    );

    BranchAddrGen bag(
        .pc(prev.pc),
        .rs(prev.alu_a),
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