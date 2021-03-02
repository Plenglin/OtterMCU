`timescale 1ns / 1ps

module BranchAddrGen(
    input [31:0] pc,
    input [31:0] rs1,
    input [31:0] b_type_imm,
    input [31:0] i_type_imm,
    input [31:0] j_type_imm,
    input opcode_t opcode,
    output logic [31:0] target
    );
    
    always_comb case (opcode)
        BRANCH: 
            target = pc + b_type_imm;
        JAL:
            target = pc + j_type_imm;
        JALR:
            target = rs1 + i_type_imm;
        default:
            target = 32'hDEADBEEF;
    endcase
    
endmodule
