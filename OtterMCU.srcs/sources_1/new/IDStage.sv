import Types::*;

module IDStage(
    input [31:0] ir,
    input [31:0] pc,
    output [4:0] adr1,
    output [4:0] adr2,
    input [31:0] rs1,
    input [31:0] rs2,
    output IDEX_t result
);

    opcode_t opcode;
    assign opcode = opcode_t'(ir[6:0]);
    func3_t func3;
    assign func3 = func3_t'(ir[14:12]);
    alusrcA_t srcA;
    alusrcB_t srcB;
    CU_DCDR cu_dcdr(
        .ir(ir),
        
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

    logic [31:0] i_imm, u_imm, s_imm;
    ImmedGen imm_gen(
        .ir(ir[31:7]),
        .j_type_imm(result.j_imm),
        .i_type_imm(i_imm),
        .b_type_imm(result.b_imm),
        .u_type_imm(u_imm),
        .s_type_imm(s_imm)
    );
        
    assign adr1 = ir[19:15];
    assign adr2 = ir[24:20];
    
    always_comb case(srcA) 
        alusrc_a_RS1: result.alu_a = rs1;
        alusrc_a_UIMM: result.alu_a = u_imm;
    endcase
    assign result.alu_a_adr = (srcA == alusrc_a_RS1) ? adr1 : 0;
        
    always_comb case(srcB)
        alusrc_b_RS2: result.alu_b = rs2;
        alusrc_b_IIMM: result.alu_b = i_imm;
        alusrc_b_SIMM: result.alu_b = s_imm;
        alusrc_b_PC: result.alu_b = pc;
    endcase
    assign result.alu_b_adr = (srcB == alusrc_b_RS2) ? adr2 : 0;
    
    assign result.pc = pc;
    
    assign result.mem.size = ir[13:12];
    assign result.mem.sign = ir[14];
    assign result.mem.rs2 = rs2; 
    assign result.mem.rs2_adr = adr2; 
    assign result.i_imm = i_imm;
    assign result.func3 = func3;
    assign result.opcode = opcode;
    assign result.wb.wa = ir[11:7];
endmodule
