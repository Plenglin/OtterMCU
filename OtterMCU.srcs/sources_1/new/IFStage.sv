`include "Types.sv"

module IFStage(
    input clk,
    input reset,
    input pcsrc_t pc_source,
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
        pcsrc_NEXT: pc_next = pc + 4;
        pcsrc_JALR: pc_next = jalr;
        pcsrc_BRANCH: pc_next = branch;
        pcsrc_JAL: pc_next = jal;
        pcsrc_MTVEC: pc_next = 0;  // TODO
        default: pc_next = 32'hDEADBEEF;  // TODO
    endcase
endmodule