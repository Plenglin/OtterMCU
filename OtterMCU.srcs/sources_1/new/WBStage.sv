`timescale 1ns / 1ps

module WBStage(
    input MEMWB_t prev,
    input [31:0] mem_dout,
    output logic [31:0] wd,
    output [4:0] wa,
    output we
    );
    
    assign we = prev.wb.rf_wr_en;
    assign wa = prev.wb.wa;
    always_comb case(prev.wb.rf_wr_sel)
        4'd0: wd = prev.pc + 4;
        4'd1: wd = 0;  // CSR reg
        4'd2: wd = mem_dout;
        4'd3: wd = prev.alu_result;
    endcase
endmodule
