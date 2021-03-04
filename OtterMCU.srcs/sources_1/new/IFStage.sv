import Types::*;

module IFStage(
    input clk,
    input reset,
    input pc_write,
    
    IBranchControlUnit.IF bcu,
     
    output [31:0] pc
);
    logic [31:0] pc_next;
    ProgramCounter program_counter(
        .clk(clk), 
        .rst(reset), 
        .next(bcu.if_pc_d),
        .pc(pc), 
        .pc_write(pc_write)
    );
    assign bcu.if_pc = pc;
endmodule