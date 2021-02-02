`include "Types.sv"

module IDStage(
    input IFID_t prev,
    RegFile regfile,
    output IDEX_t result
);

    CU_DCDR cu_dcdr(
        .opcode(prev.ir[6:0]),
        .func7(prev.ir[31:25]),
        .func3(prev.ir[14:12]),
        
        .int_taken(int_taken),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu)
    );

    ImmedGen imm_gen(.ir(prev.ir));
    
    assign result.alu_a = cu_dcdr.alu_src_a
            ? imm_gen.u_type_imm 
            : regfile.rs1;
        
    always_comb case(cu_dcdr.alu_src_b)
        4'd0: result.alu_b = regfile.rs2;
        4'd1: result.alu_b = imm_gen.i_type_imm;
        4'd2: result.alu_b = imm_gen.s_type_imm;
        4'd3: result.alu_b = prev.pc;
    endcase
    
    assign result.wb.rf_wr_sel = cu_dcdr.rf_wr_sel;
endmodule
