`timescale 1ns / 1ps

module HazardDetection(
    input idex_mem_read,
    input [4:0] idex_wb_wa,
    input [4:0] ifid_adr1,
    input [4:0] ifid_adr2,
    output stall
    );
    
    assign stall = idex_mem_read & (
        idex_wb_wa == ifid_adr1 | idex_wb_wa == ifid_adr2
    );
    
endmodule
