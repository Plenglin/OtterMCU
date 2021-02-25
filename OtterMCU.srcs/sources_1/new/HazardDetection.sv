`timescale 1ns / 1ps

module HazardDetection(
    input clk,
    input idex_mem_read,
    input [4:0] idex_wb_wa,
    input [4:0] ifid_adr1,
    input [4:0] ifid_adr2,
    input [31:0] ir_fetched,
    output logic [31:0] ir,
    output stall
    );
    
    assign stall = idex_mem_read & idex_wb_wa != 0 & (
        idex_wb_wa == ifid_adr1 | idex_wb_wa == ifid_adr2
    );
    
    reg [31:0] ir_reg;
    reg stalled_last = 0;
    
    always_ff @(posedge clk)
        if (stall) begin 
            ir_reg = ir_fetched;
            stalled_last = 1;
        end else 
            stalled_last = 0;
    
    assign ir = stalled_last ? ir_reg : ir_fetched; 
    
endmodule
