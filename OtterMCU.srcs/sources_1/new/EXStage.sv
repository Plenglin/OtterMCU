`include "Types.sv"

module EXStage(
    input clk,
    input reset,
    input IDEX_t prev,
    output EXMEM_t result,
    output [31:0] jal,
    output [31:0] jalr,
    output [31:0] branch
);
    ALU alu(
        .srcA(prev.alu_a), 
        .srcB(prev.alu_b), 
        .alu_fun(prev.alu_fun)
    );
    
    BranchCondGen bcg(
        .rs1(prev.alu_a),
        .rs2(prev.alu_b)
    );
    BranchAddrGen bag();
    
    assign result.pc = prev.pc;
    assign result.mem = prev.mem;
    assign result.wb = prev.wb;
    assign result.alu_result = alu.result;
endmodule