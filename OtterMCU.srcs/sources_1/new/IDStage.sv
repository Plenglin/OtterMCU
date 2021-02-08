`include "Types.sv"

module IDStage(
    input [31:0] ir,
    input [31:0] pc,
    output [4:0] adr1,
    output [4:0] adr2,
    input [31:0] rs1,
    input [31:0] rs2,
    output IDEX_t result
);

    alusrcA_t srcA;
    alusrcB_t srcB;
    CU_DCDR cu_dcdr(
        .opcode(ir[6:0]),
        .func7(ir[31:25]),
        .func3(ir[14:12]),
        
        .int_taken(int_taken),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu),
        .alu_srcA(srcA),
        .alu_srcB(srcB),
        .alu_fun(result.alu_fun),
        
        .rf_wr_sel(result.wb.rf_wr_sel),
        .rf_wr_en(result.wb.rf_wr_en),
        
        .mem_read(result.mem.read),
        .mem_write(result.mem.write)
    );

    logic [31:0] u_imm, s_imm;
    ImmedGen imm_gen(
        .ir(ir[31:7]),
        .j_type_imm(result.j_imm),
        .i_type_imm(result.i_imm),
        .b_type_imm(result.b_imm),
        .u_type_imm(u_imm),
        .s_type_imm(s_imm)
    );
        
    assign adr1 = ir[19:15];
    assign adr2 = ir[24:20];
    
    assign result.alu_a = srcA
            ? u_imm 
            : rs1;
        
    always_comb case(srcB)
        4'd0: result.alu_b = rs2;
        4'd1: result.alu_b = result.i_imm;
        4'd2: result.alu_b = s_imm;
        4'd3: result.alu_b = pc;
    endcase
    
    assign result.pc = pc;
    
    assign result.mem.size = ir[13:12];
    assign result.mem.sign = ir[14];
    assign result.mem.rs2 = rs2; 
    assign result.wb.wa = ir[11:7];
endmodule
