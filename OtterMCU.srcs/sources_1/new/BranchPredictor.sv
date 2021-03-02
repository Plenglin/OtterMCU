import Types::*;

interface BranchPredictor(
    input clk,
    input reset
);
    logic id_is_branch;
    func3_t id_branch_type;
    logic [31:0] id_pc;
    
    logic ex_branched;
    func3_t ex_branch_type;
    logic [31:0] ex_pc;
    
    logic should_branch;

    modport Predictor(
        input id_is_branch,
        input id_branch_type,
        input id_pc,
        
        input ex_branched,
        input ex_branch_type,
        input ex_pc,
        
        output should_branch
    );
    
    modport ID(
        output id_is_branch,
        output id_branch_type,
        output id_pc,
        input should_branch
    );
    
    modport EX(
        output ex_branched,
        output ex_branch_type,
        output ex_pc
    );
endinterface