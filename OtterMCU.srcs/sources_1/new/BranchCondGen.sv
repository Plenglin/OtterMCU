`timescale 1ns / 1ps
`include "Types.sv"

module BranchCondGen(
    input opcode_t opcode,
    input [2:0] func3,
    input [31:0] rs1,
    input [31:0] rs2,
    output pcsrc_t pcSource
    );
    
    // Branch condition selector
    logic raw_branch_cond;
    always_comb case(func3[2:1])
        2'b00: raw_branch_cond = rs1 == rs2;     // BEQ, BNE
        2'b10: raw_branch_cond = $signed(rs1) < $signed(rs2);     // BLT, BGE
        2'b11: raw_branch_cond = rs1 < rs2;    // BLTU, BGEU
        default: raw_branch_cond = 0;       // ruh roh
    endcase
    
    logic branch_cond;
    assign branch_cond = raw_branch_cond ^ func3[0];
     
    always_comb case(opcode)
        JAL: begin 
            pcSource = pcsrc_JAL;
        end 
         
        JALR: begin 
            pcSource = pcsrc_JALR;
        end
         
        BRANCH: begin 
            pcSource = branch_cond   
                ? pcsrc_BRANCH 
                : pcsrc_NEXT; 
        end 
        
        default: begin
            pcSource = pcsrc_NEXT;
        end
    endcase
    
    
endmodule
