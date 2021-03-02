`timescale 1ns / 1ps

import Types::*;

module BranchControlUnit(
    IBranchControlUnit.BCU iface
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
    
    always_comb begin
        iface.flush_ifid = 0;
        iface.flush_idex = 0;
        pc_source = src_next;
        
        if (iface.ex_correct) begin  // we were correct
            if (iface.ex_status == confirm_br) begin
                pc_source = src_next;
                iface.flush_ifid = 0;
                iface.flush_idex = 1;
            end else if (iface.ex_status == rollback_nobr) begin
                pc_source = src_ex_target;
                iface.flush_ifid = 1;
                iface.flush_idex = 1;
            end 
        end else begin  // we were not correct
            if (id_predict_br) begin
                if (iface.ex_status == rollback_br) begin
                    iface.flush_ifid = 1;
                    pc_source = src_ex_subsequent; 
                end else
                    pc_source = src_next;
            end else begin 
                pc_source = src_id_target;
                if (iface.id_status == predict_jump) begin
                    iface.flush_ifid = 1;
                    iface.flush_idex = 1;
                end else if (iface.ex_status == rollback_br)
                    iface.flush_ifid = 1;
            end
        end
    end
    
    always_comb case (pc_source)
        src_next: 
            iface.pc_d = iface.if_pc + 4;
        src_ex_target: 
            iface.pc_d = iface.ex_target;
        src_id_target: 
            iface.pc_d = iface.id_target;
        src_ex_subsequent: 
            iface.pc_d = iface.ex_pc + 8;
    endcase
endmodule
