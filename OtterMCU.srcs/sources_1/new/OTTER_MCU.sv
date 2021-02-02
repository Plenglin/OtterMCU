`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: PIPELINED_OTTER_CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic [6:0] {
    LUI      = 7'b0110111,
    AUIPC    = 7'b0010111,
    JAL      = 7'b1101111,
    JALR     = 7'b1100111,
    BRANCH   = 7'b1100011,
    LOAD     = 7'b0000011,
    STORE    = 7'b0100011,
    OP_IMM   = 7'b0010011,
    OP       = 7'b0110011,
    SYSTEM   = 7'b1110011
} opcode_t;
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
} instr_t;

module OTTER_MCU #(parameter MEM_FILE="otter_memory.mem")
(
    input CLK,
    input INTR,
    input RESET,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR 
);           
    wire [6:0] opcode;
    wire [31:0] pc, pc_value, next_pc, jalr_pc, branch_pc, jump_pc, int_pc,A,B,
        I_immed,S_immed,U_immed,aluBin,aluAin,aluResult,rfIn,csr_reg, mem_data;
    
    wire memRead1,memRead2;

    wire pcWrite,regWrite,memWrite, op1_sel,mem_op,IorD,pcWriteCond,memRead;
    wire [1:0] opB_sel, rf_sel, wb_sel, mSize;
    logic [1:0] pc_sel;
    wire [3:0]alu_fun;
    wire opA_sel;
    
    Memory memory;

    logic br_lt,br_eq,br_ltu;
              
//==== Instruction Fetch ===========================================

    assign pcWrite = 1'b1;  //Hardwired high, assuming now hazards
    assign memRead1 = 1'b1;     //Fetch new instruction every cycle
    ProgramCounter program_counter(.rst(RESET), .pc(pc), .pc_write(pcWrite));    

    logic [31:0] if_de_pc;
    always_ff @(posedge CLK) begin
        if_de_pc <= pc;
    end
    
    assign mem.MEM_ADDR1 = pc;     
    wire [31:0] IR;
    assign IR = mem.MEM_DOUT1;
    
//==== Instruction Decode ===========================================
    logic [31:0] de_ex_rs2;

    instr_t de_ex_inst, de_inst;
    
    opcode_t OPCODE;
    assign opcode = IR[6:0];
    assign OPCODE_t = opcode_t'(opcode);
    
    assign de_inst.rs1_addr = IR[19:15];
    assign de_inst.rs2_addr = IR[24:20];
    assign de_inst.rd_addr = IR[11:7];
    assign de_inst.opcode = OPCODE;
   
    assign de_inst.rs1_used =   de_inst.rs1 != 0
                                && de_inst.opcode != LUI
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != JAL;
    BranchCondGen bcg(
        .rs1(rs1),
        .rs2(rs2),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu)
    );
    
    ImmedGen imm_gen(.ir(IR));
    
    logic [31:0] de_ex_opA;
    always_ff @(posedge CLK)
        de_ex_opA <= alu_src_a 
            ? imm_gen.u_type_imm 
            : rs1;
        
    logic [31:0] de_ex_opB;
    always_ff @(posedge CLK) case(alu_src_b)
        4'd0: de_ex_opB <= rs2;
        4'd1: de_ex_opB <= imm_gen.i_type_imm;
        4'd2: de_ex_opB <= imm_gen.s_type_imm;
        4'd3: de_ex_opB <= pc;
    endcase

    CU_DCDR cu_dcdr(
        .opcode(IR[6:0]),
        .func7(IR[31:25]),
        .func3(IR[14:12]),
        
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
    
    RegFile reg_file;
    assign de_ex_opA = reg_file.rs1;
    assign de_ex_opB = reg_file.rs2;
    
//==== Execute ======================================================
    logic [31:0] ex_mem_rs2;
    logic ex_mem_aluRes = 0;
    instr_t ex_mem_inst;
    logic [31:0] opA_forwarded;
    logic [31:0] opB_forwarded;
     
     // Creates a RISC-V ALU
    ALU alu(de_ex_inst.alu_fun, de_ex_opA, de_ex_opB, aluResult); // the ALU
     
    
//==== Memory ======================================================
     
     
    assign IOBUS_ADDR = ex_mem_aluRes;
    assign IOBUS_OUT = ex_mem_rs2;
    
 
 
 
     
//==== Write Back ==================================================
     


 
 

       
            
endmodule
