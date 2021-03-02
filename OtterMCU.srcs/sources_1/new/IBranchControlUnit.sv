`timescale 1ns / 1ps

import Types::*;

interface IBranchControlUnit;
    logic [31:0] if_pc;
    logic [31:0] if_pc_d;

    br_predict_t id_status;
    logic [31:0] id_target;
    
    br_certain_t ex_status;
    logic [31:0] ex_pc;
    logic [31:0] ex_target;
    
    logic flush_ifid;
    logic flush_idex;
    
    modport BCU(
        input if_pc,
        
        input id_status,
        input id_target,
        
        input ex_status,
        input ex_pc,
        input ex_target,
        
        output flush_ifid,
        output flush_idex,
        output if_pc_d
    );
    
    modport IF(
        output if_pc,
        input if_pc_d
    );
    
    modport EX(
        output ex_status,
        output ex_pc,
        output ex_target
    );

    modport ID(
        output id_status,
        output id_target
    );               
endinterface
