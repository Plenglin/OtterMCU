`include "Types.sv"

module IFStage(
    input clk,
    input reset,
    input [1:0] pc_source,
    input pc_write,
    input [31:0] jal,
    input [31:0] branch,
    input [31:0] jalr,
    output [31:0] pc
);
    logic [31:0] pc_next;
    ProgramCounter program_counter(
        .clk(clk), 
        .rst(reset), 
        .next(pc_next),
        .pc(pc), 
        .pc_write(pc_write)
    );

    always_comb case(pc_source)
        4'd0: pc_next = pc + 4;
        4'd1: pc_next = jalr;
        4'd2: pc_next = branch;
        4'd3: pc_next = jal;
    endcase
        
    assign pc = program_counter.pc;
endmodule