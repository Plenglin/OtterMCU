`timescale 1ns / 1ps

import Types::*;

module BranchControlUnit(
    IBranchControlUnit.BCU iface,
    input clk,
    input reset,
    output branch_perf performance
);
    
    assign ex_is_branch = iface.ex_status[2];
    assign ex_correct = iface.ex_status[1];
    assign ex_certain_br = iface.ex_status[0];
    
    assign id_is_branch = iface.id_status[1];
    assign id_predict_br = iface.id_status[0];
        
    typedef enum logic [1:0] {
        src_next = 0,
        src_ex_target = 1,
        src_id_target = 2,
        src_ex_subsequent = 3
    } pc_source_t;
    pc_source_t pc_source;
    
    logic flush_ifid, flush_idex;
    always_comb begin
        flush_ifid = 0;
        flush_idex = 0;
        pc_source = src_next;
        
        if (ex_certain_br) begin  // EX wants to jump
            if (iface.ex_status == confirm_br) begin  // confirming a branch
                pc_source = src_next;
                flush_idex = 1;
            end else begin  // rolling back a mispredicted no-branch, or performing a JALR
                pc_source = src_ex_target;
                flush_ifid = 1;
                flush_idex = 1;
            end 
        end else begin  // we should not have branched
            if (id_predict_br) begin  // predicting a new branch
                pc_source = src_id_target;
                if (iface.id_status == predict_jump) begin
                    flush_ifid = 1;
                end else if (iface.ex_status == rollback_br)
                    flush_ifid = 1;
            end else begin  // predict no branch
                if (iface.ex_status == rollback_br) begin
                    flush_ifid = 1;
                    pc_source = src_ex_subsequent; 
                end else
                    pc_source = src_next;
            end
        end
    end
    assign iface.flush_ifid = flush_ifid;
    assign iface.flush_idex = flush_idex;
    
    always_comb case (pc_source)
        src_next: 
            iface.if_pc_d = iface.if_pc + 4;
        src_ex_target: 
            iface.if_pc_d = iface.ex_target;
        src_id_target: 
            iface.if_pc_d = iface.id_target;
        src_ex_subsequent: 
            iface.if_pc_d = iface.ex_pc + 8;
    endcase
    
    branch_perf perf = branch_perf'{
        correct_br: 0, 
        correct_nobr: 0, 
        wrong_br: 0, 
        wrong_nobr: 0,
        flushes: 0
    };
    
    logic [1:0] flushes;
    assign flushes = 2'(flush_ifid) + 2'(flush_idex);
    
    always_ff @(posedge clk) begin
        perf.flushes += flushes;
        
        if (reset) begin
            perf.correct_br <= 32'b0;
            perf.correct_nobr <= 32'b0;
            perf.wrong_br <= 32'b0;
            perf.wrong_nobr <= 32'b0;
            perf.flushes <= 32'b0;
        end else case (iface.ex_status)
            confirm_br: 
                perf.correct_br <= 1 + perf.correct_br;
            confirm_nobr: 
                perf.correct_nobr <= 1 + perf.correct_nobr;
            rollback_br: 
                perf.wrong_br <= 1 + perf.wrong_br;
            rollback_nobr: 
                perf.wrong_nobr <= 1 + perf.wrong_nobr;
        endcase
    end
    assign performance = perf;
endmodule
