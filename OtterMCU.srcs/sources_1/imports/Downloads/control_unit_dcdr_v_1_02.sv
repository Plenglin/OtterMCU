`timescale 1ns / 1ps

module CU_DCDR(
    input br_eq, 
    input br_lt, 
    input br_ltu,
    input int_taken,
    
    input [6:0] opcode,   //-  ir[6:0]
    input [6:0] func7,    //-  ir[31:25]
    input [2:0] func3,    //-  ir[14:12] 
    output logic [3:0] alu_fun,
    output logic [2:0] pcSource,
    output logic alu_srcA,
    output logic [1:0] alu_srcB, 
    output logic [1:0] rf_wr_sel,
    output logic [1:0] rf_wr_en,
    
    output logic mem_write,
    output logic mem_read
    );
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        OP_INT = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    //- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_t;    
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
        pcSource = 3'd0; // next
        rf_wr_sel = 2'd0;  // pc_inc 
        rf_wr_en = 0;
        
        alu_srcA = 1'b0;   
        alu_srcB = 2'b00;    
        alu_fun  = 4'b0000;
        
        mem_read = 0;
        mem_write = 0;
        
        if (int_taken) begin
            pcSource = 3'd4;  // mtvec 
        end else case(OPCODE)
            LUI: begin
                rf_wr_en = 1;
                alu_fun = 4'b1001;   // lui
                alu_srcA = 1;        // u-imm 
                rf_wr_sel = 2'b11;   // alu_result
            end
            
            AUIPC: begin
                rf_wr_en = 1;
                alu_fun = 4'b0000;   // add
                alu_srcA = 1;        // u-imm
                alu_srcB = 2'd3;     // pc
                rf_wr_sel = 2'd3;   // alu_result
            end
            
            JAL: begin
                rf_wr_en = 1;
                rf_wr_sel = 2'd0;   // next pc
                pcSource = 3'd3;     // jal
            end
            
            JALR: begin
                rf_wr_en = 1;
                rf_wr_sel = 2'd0;   // next pc
                pcSource = 3'd1;       // jalr
            end
            
            LOAD: begin
                alu_fun = 4'b0000;     // add
                alu_srcA = 0;          // rs1
                alu_srcB = 2'd1;       // i imm
                rf_wr_sel = 2'd2;      // mem dout
                mem_read = 1;
            end
            
            STORE: begin
                rf_wr_en = 1;
                alu_fun = 4'b0000;     // add
                alu_srcA = 1'b0;       // rs1
                alu_srcB = 2'd2;       // s imm
                mem_write = 1;
            end
            
            BRANCH: begin
                pcSource = branch_cond   // Invert if invert bit 
                    ? 3'd2      // Condition success, branch
                    : 3'd0;     // Condition fail, next
            end
            
            OP_IMM: begin
                pcSource = 3'd0;  // next
                alu_srcA = 1'b0;   // rs1
                alu_srcB = 2'd1;   // i imm
                rf_wr_sel = 2'd3;  // alu result
                alu_fun = op_alu_fun;  // translated func
            end
            
            OP_RG3: begin
                rf_wr_en = 1;
                pcSource = 3'd0;  // next
                alu_srcA = 0;   // rs1
                alu_srcB = 2'd0;   // rs2
                rf_wr_sel = 2'd3;  // alu result
                alu_fun = op_alu_fun;  // translated func             
            end
            
            OP_INT: if (func3[0]) begin  // csrrw
                rf_wr_en = 1;
                rf_wr_sel = 2'd1;  // csr_reg
                pcSource = 3'd0;  // next
            end else begin  // mret
                pcSource = 3'd5;  // mepc
            end

            default: begin
                 pcSource = 3'd0; 
                 alu_srcB = 2'b00; 
                 rf_wr_sel = 2'b00; 
                 alu_srcA = 1'b0; 
                 alu_fun = 4'b0000;
            end
        endcase
    end

endmodule