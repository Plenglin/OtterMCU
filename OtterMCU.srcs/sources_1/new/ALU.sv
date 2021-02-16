`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Astrid Yu
// 
// Create Date: 04/19/2020 08:07:54 PM
// Design Name: Otter MCU ALU
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Performs arithmetic operations for the Otter MCU.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import Types::*;

module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input alufun_t alu_fun,
    output logic [31:0] result
    );
    
    logic [4:0] shiftB;
    assign shiftB = srcB[4:0];
        
    always_comb begin
        case (alu_fun)
            alufun_ADD:       result = srcA + srcB;
            alufun_SUB:       result = srcA - srcB;
            alufun_OR:        result = srcA | srcB;
            alufun_AND:       result = srcA & srcB;
            alufun_XOR:       result = srcA ^ srcB;
            alufun_SRL:       result = srcA >> shiftB;
            alufun_SLL:       result = srcA << shiftB;
            alufun_SRA:       result = $signed(srcA) >>> shiftB;
            alufun_SLT:       result = $signed(srcA) < $signed(srcB);
            alufun_SLTU:      result = srcA < srcB;
            alufun_LUI:       result = srcA;
            default: result = 32'hDEADBEEF;
        endcase
    end
endmodule
