`timescale 1ns / 1ps

module WBStage(
    input MEMWB_t prev,
    output [31:0] wd,
    output [4:0] wa,
    output we
    );
    
    assign we = prev.wb.we;
    assign wa = prev.wb.wa;
    assign en = prev.wb.reg_wr_en;
    always_comb case(prev.wb.rf_wr_sel)
        4'd0: regfile.wd = prev.pc + 4;
        4'd1: regfile.wd = 0;  // CSR reg
        4'd2: regfile.wd = memory.MEM_DOUT2;
        4'd3: regfile.wd = prev.alu_result;
    endcase
endmodule
