import Types::*;

module EXStage(
    input clk,
    input reset,
    input IDEX_t prev,
    
    input [4:0] exmem_wa,
    input [31:0] exmem_data,
    input exmem_we,
    
    input [4:0] memwb_wa,
    input [31:0] memwb_data,
    input memwb_we,
    
    BranchPredictor.EX predictor,
    IBranchControlUnit.EX bcu,
    
    output idex_mem_read,
    output [4:0] idex_wb_wa,
    
    output EXMEM_t result
);

    assign idex_mem_read = prev.mem.read;
    assign idex_wb_wa = prev.wb.wa;

    logic [31:0] alu_a;
    ForwardingUnit fu_a(
        .idex_adr(prev.alu_a_adr),
        .idex_data(prev.alu_a),
        
        .exmem_wa(exmem_wa),
        .exmem_data(exmem_data),
        .exmem_we(exmem_we),
        
        .memwb_wa(memwb_wa),
        .memwb_data(memwb_data),
        .memwb_we(memwb_we),
        
        .alu_arg(alu_a)
    );
    
    logic [31:0] alu_b;
    ForwardingUnit fu_b(
        .idex_adr(prev.alu_b_adr),
        .idex_data(prev.alu_b),
        
        .exmem_wa(exmem_wa),
        .exmem_data(exmem_data),
        .exmem_we(exmem_we),
        
        .memwb_wa(memwb_wa),
        .memwb_data(memwb_data),
        .memwb_we(memwb_we),
        
        .alu_arg(alu_b)
    );
    
    ALU alu(
        .srcA(alu_a), 
        .srcB(alu_b), 
        .alu_fun(prev.alu_fun),
        .result(result.alu_result)
    );
    
    logic should_branch;
    BranchCondGen bcg(
        .rs1(alu_a),
        .rs2(alu_b),
        .opcode(prev.opcode),
        .func3(prev.func3),
        .should_branch(should_branch)
    );
    
    always_comb case (prev.branch_status) inside
        predict_none, predict_jump: 
            bcu.ex_status = ex_normal;
        predict_br:
            bcu.ex_status = should_branch ? confirm_br : rollback_br;
        predict_nobr:
            bcu.ex_status = should_branch ? rollback_nobr : confirm_br;
    endcase
    assign predictor.ex_branched = should_branch;
    assign predictor.ex_branch_type = prev.func3;
    assign predictor.ex_pc = prev.pc;
    
    assign bcu.ex_pc = prev.pc;
    assign bcu.ex_target = prev.jump_target; 
    
    // Forwarding for store instructions
    logic [31:0] mem_rs2;
    ForwardingUnit fu_mem_rs2(
        .idex_adr(prev.mem.rs2_adr),
        .idex_data(prev.mem.rs2),
        
        .exmem_wa(exmem_wa),
        .exmem_data(exmem_data),
        .exmem_we(exmem_we),
        
        .memwb_wa(memwb_wa),
        .memwb_data(memwb_data),
        .memwb_we(memwb_we),
        
        .alu_arg(mem_rs2)
    );
    
    assign result.pc = prev.pc;
    assign result.mem = prev.mem;
    assign result.mem.rs2 = mem_rs2;
    assign result.wb = prev.wb;
endmodule