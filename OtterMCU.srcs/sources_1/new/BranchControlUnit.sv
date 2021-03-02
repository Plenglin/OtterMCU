`timescale 1ns / 1ps

import Types::*;

module BranchControlUnit(
    input logic [31:0] if_pc,
    
    input br_predict_t id_status,
    input logic [31:0] id_target,
    
    input br_certain_t ex_status,
    input logic [31:0] ex_pc,
    input logic [31:0] ex_target,
    
    output logic flush_ifid,
    output logic flush_idex,
    output logic [31:0] pc_d
    );
    
    assign ex_is_branch = ex_status[2];
    assign ex_correct = ex_status[1];
    assign ex_certain_br = ex_status[0];
    
    assign id_is_branch = id_status[1];
    assign id_predict_br = id_status[0];
    
    typedef enum logic [1:0] {
        src_next = 0,
        src_ex_target = 1,
        src_id_target = 2,
        src_ex_subsequent = 3
    } pc_source_t;
    pc_source_t pc_source;
    
    always_comb begin
        flush_ifid = 0;
        flush_idex = 0;
        pc_source = src_next;
        
        if (ex_correct) begin  // we were correct
            if (ex_status == confirm_br) begin
                pc_source = src_next;
                flush_ifid = 0;
                flush_idex = 1;
            end else if (ex_status == rollback_nobr) begin
                pc_source = src_ex_target;
                flush_ifid = 1;
                flush_idex = 1;
            end 
        end else begin  // we were not correct
            if (id_predict_br) begin
                if (ex_status == rollback_br) begin
                    flush_ifid = 1;
                    pc_source = src_ex_subsequent; 
                end else
                    pc_source = src_next;
            end else begin 
                pc_source = src_id_target;
                if (id_status == predict_jump) begin
                    flush_ifid = 1;
                    flush_idex = 1;
                end else if (ex_status == rollback_br)
                    flush_ifid = 1;
            end
        end
    end
    
    always_comb case (pc_source)
        src_next: pc_d = if_pc + 4;
        src_ex_target: pc_d = ex_target;
        src_id_target: pc_d = id_target;
        src_ex_subsequent: pc_d = ex_pc + 8;
    endcase
endmodule
