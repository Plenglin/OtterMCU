`include "Types.sv"

module EXStage(
    input clk,
    input reset,
    input IDEX_t prev,
    output EXMEM_t result
);

    ALU alu(
        .srcA(prev.alu_a), 
        .srcB(prev.alu_b), 
        .alu_fun(prev.alu_fun)
    );
    
    BranchCondGen bcg();
    BranchAddrGen bag();
        
    always_ff@(posedge clk) begin
        result.mem <= prev.mem;
        result.wb <= prev.wb;
        result.alu_result <= alu.result;
    end
endmodule