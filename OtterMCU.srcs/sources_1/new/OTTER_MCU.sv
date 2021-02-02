`timescale 1ns / 1ps

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
    logic [3:0] alu_fun;
    logic [31:0] alu_a;
    logic [31:0] alu_b;
} st_EX_t;

typedef struct packed{
    logic alu_src;
    logic [3:0] alu_fun;
} st_MEM_t;

typedef struct packed{
    logic alu_src;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
} st_WB_t;

typedef struct packed{
    logic [31:0] pc;
    logic [31:0] ir;
} IFID_t;

typedef struct packed{
    logic [31:0] pc;
    st_EX_t ex;
    st_M_t m;
    st_WB_t wb;
} IDEX_t;

typedef struct packed{
    logic [31:0] pc;
    logic [31:0] reg_1;
    logic [31:0] reg_2;
    opcode_t opcode;
    st_M_t m;
    st_WB_t wb;
} EXM_t;

typedef struct packed{
    logic [31:0] pc;
    logic [31:0] reg_1;
    logic [31:0] reg_2;
    opcode_t opcode;
    st_WB_t wb;
} MWB_t;

module IFStage(
    input clk,
    input reset,
    input [1:0] pcSource,
    input pc_write,
    Memory mem,
    output IFID_t result
);
    ProgramCounter program_counter(.clk(clk), .rst(reset), .pc(pc), .pc_write(pc_write));
    
    assign mem.MEM_ADDR1 = program_counter.pc;
    
    always_ff @(posedge clk) begin
        result.ir <= mem.MEM_DOUT1;
        result.pc <= program_counter.pc; 
    end
endmodule

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

module EXStage(
);
    BranchCondGen bcg(
        .rs1(rs1),
        .rs2(rs2),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu)
    );
endmodule

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
    assign pc_write = 1'b1;
    assign mem_read1 = 1'b1;
    
    Memory #(.MEM_FILE(MEM_FILE)) memory(.MEM_RDEN1(mem_read1));
    RegFile regfile;
              
    IFStage if_stage(
        .clk(CLK),
        .reset(RESET),
        .mem(memory),
        .pc_write(pc_write)
    );
        
    IDStage id_stage(
        .clk(CLK),
        .reset(RESET),
        .ir(if_stage.ir)
        .regfile(regfile)
    );
    
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
