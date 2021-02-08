`timescale 1ns / 1ps
import Types::*;

module CU_DCDR(
    input br_eq, 
    input br_lt, 
    input br_ltu,
    input int_taken,
    input [31:0] ir,
    output alufun_t alu_fun,
    output alusrcA_t alu_srcA,
    output alusrcB_t alu_srcB, 
    output logic [1:0] rf_wr_sel,
    output logic rf_wr_en,
    
    output logic mem_write,
    output logic mem_read
    );
    
    logic [6:0] func7;
    logic [2:0] func3;
    assign func7 = ir[31:25]; 
    assign func3 = ir[14:12]; 
    
    opcode_t OPCODE; //- define variable of new opcode type
    assign OPCODE = opcode_t'(ir[6:0]); //- Cast input enum 

    func3_t FUNC3; //- define variable of new opcode type
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
    
    // Branch condition selector
    logic raw_branch_cond;
    always_comb case(func3[2:1])
        2'b00: raw_branch_cond = br_eq;     // BEQ, BNE
        2'b10: raw_branch_cond = br_lt;     // BLT, BGE
        2'b11: raw_branch_cond = br_ltu;    // BLTU, BGEU
        default: raw_branch_cond = 0;       // ruh roh
    endcase
    
    logic branch_cond;
    assign branch_cond = raw_branch_cond ^ func3[0];
    
    logic alu_flag;
    assign alu_flag = func7[5];
    
    logic [3:0] op_alu_fun;
    always_comb case(func3) inside
        3'b?01: op_alu_fun = {alu_flag, func3};
        3'b000: op_alu_fun = {alu_flag & (OPCODE == OP_RG3), func3};
        default: op_alu_fun = {1'b0, func3};
    endcase
       
    always_comb begin 
        //- schedule all values to avoid latch
        rf_wr_sel = 2'd0;  // pc_inc 
        rf_wr_en = 0;
        
        alu_srcA = alusrc_a_RS1;   
        alu_srcB = alusrc_b_RS2;    
        alu_fun = alufun_ADD;
        
        mem_read = 0;
        mem_write = 0;
        
        if (int_taken) begin
        end else case(OPCODE)
            LUI: begin
                rf_wr_en = 1;
                alu_fun = alufun_LUI; 
                alu_srcA = alusrc_a_UIMM;
                rf_wr_sel = 2'b11;   // alu_result
            end
            
            AUIPC: begin
                rf_wr_en = 1;
                alu_fun = alufun_ADD;
                alu_srcA = alusrc_a_UIMM;        // u-imm
                alu_srcB = alusrc_b_PC;     // pc
                rf_wr_sel = 2'd3;   // alu_result
            end
            
            JAL: begin
                rf_wr_en = 1;
                rf_wr_sel = 2'd0;   // next pc
            end
            
            JALR: begin
                rf_wr_en = 1;
                rf_wr_sel = 2'd0;   // next pc
            end
            
            BRANCH: begin
                alu_srcA = alusrc_a_RS1;
                alu_srcB = alusrc_b_RS2;
            end
            
            LOAD: begin
                alu_fun = alufun_ADD;     // add
                alu_srcA = alusrc_a_RS1;          // rs1
                alu_srcB = alusrc_b_IIMM;       // i imm
                rf_wr_sel = 2'd2;      // mem dout
                rf_wr_en = 1;
                mem_read = 1;
            end
            
            STORE: begin
                alu_fun = alufun_ADD;     // add
                alu_srcA = alusrc_a_RS1;       // rs1
                alu_srcB = alusrc_b_SIMM;       // s imm
                mem_write = 1;
            end
            
            OP_IMM: begin
                alu_srcA = alusrc_a_RS1;   // rs1
                alu_srcB = alusrc_b_IIMM;   // i imm
                rf_wr_sel = 2'd3;  // alu result
                alu_fun = alufun_t'(op_alu_fun);  // translated func
                rf_wr_en = 1;
            end
            
            OP_RG3: begin
                rf_wr_en = 1;
                alu_srcA = alusrc_a_RS1;   // rs1
                alu_srcB = alusrc_b_RS2;   // rs2
                rf_wr_sel = 2'd3;  // alu result
                alu_fun = alufun_t'(op_alu_fun);  // translated func             
            end
            
            OP_INT: if (func3[0]) begin  // csrrw
                rf_wr_en = 1;
                rf_wr_sel = 2'd1;  // csr_reg
            end

            default: begin
                 alu_srcA = alusrc_a_RS1; 
                 alu_srcB = alusrc_b_RS2; 
                 rf_wr_sel = 2'b00; 
                 alu_fun = alufun_ADD;
            end
        endcase
    end

endmodule