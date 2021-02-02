`include "Types.sv"

module IFStage(
    input clk,
    input reset,
    input [1:0] pcSource,
    input pc_write,
    Memory mem,
    output IFID_t result
);
    ProgramCounter program_counter(.clk(clk), .rst(reset), .pc(pc), .pc_write(pc_write));
    
    assign mem.MEM_ADDR1 = program_counter.pc;
    
    assign result.ir = mem.MEM_DOUT1;
    assign result.pc = program_counter.pc; 
endmodule