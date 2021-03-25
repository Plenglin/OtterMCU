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
        
        case (iface.ex_status) inside
            ex_jalr, rollback_nobr: begin
                pc_source = src_ex_target;
                flush_ifid = 1;
                flush_idex = 1;
            end
            confirm_br: begin
                pc_source = src_next;
                flush_idex = 1;
            end
            rollback_br: begin 
                flush_ifid = 1;
                pc_source = id_predict_br ? src_id_target : src_ex_subsequent;
            end
            default: case (iface.id_status) inside
                predict_none, predict_nobr:
                    pc_source = src_next;
                predict_br:
                    pc_source = src_id_target;
                predict_jump: begin
                    flush_ifid = 1;
                    pc_source = src_id_target;
                end
            endcase
        endcase
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
        if (reset) begin
            perf.correct_br <= 32'b0;
            perf.correct_nobr <= 32'b0;
            perf.wrong_br <= 32'b0;
            perf.wrong_nobr <= 32'b0;
            perf.flushes <= 32'b0;
        end else begin
            perf.flushes <= flushes + perf.flushes;
            case (iface.ex_status)
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
    end
    assign performance = perf;
endmodule
