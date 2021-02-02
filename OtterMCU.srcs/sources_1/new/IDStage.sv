`include "Types.sv"

module IDStage(
    input clk,
    input reset,
    input IFID_t pipe,
    RegFile regfile,
    output IDEX_t result
);

    CU_DCDR cu_dcdr(
        .opcode(ir[6:0]),
        .func7(ir[31:25]),
        .func3(ir[14:12]),
        
        .int_taken(int_taken),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu),
        
        .alu_fun(alu_fun),
        .pcSource(pc_source),
        .alu_srcA(alu_src_a),
        .alu_srcB(alu_src_b), 
        .rf_wr_sel(rf_wr_sel)
    );

    ImmedGen imm_gen(.ir(pipe.ir));
    
    logic [31:0] de_ex_opA;
    always_ff @(posedge clk)
        de_ex_opA <= alu_src_a 
            ? imm_gen.u_type_imm 
            : regfile.rs1;
        
    logic [31:0] de_ex_opB;
    always_ff @(posedge clk) case(alu_src_b)
        4'd0: de_ex_opB <= regfile.rs2;
        4'd1: de_ex_opB <= imm_gen.i_type_imm;
        4'd2: de_ex_opB <= imm_gen.s_type_imm;
        4'd3: de_ex_opB <= pipe.pc;
    endcase
    
    RegFile reg_file;
    assign de_ex_opA = reg_file.rs1;
    assign de_ex_opB = reg_file.rs2;
endmodule
