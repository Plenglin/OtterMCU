`timescale 1ns / 1ps

import Types::*;

module MultiplexedBranchPredictor(
        BranchPredictor.Predictor bp,
        input branch_predictor_t selection
    );
    logic clk;
    logic reset;
    logic id_is_branch;
    func3_t id_branch_type;
    logic [31:0] id_pc, id_target;
    
    logic ex_branched;
    func3_t ex_branch_type;
    logic [31:0] ex_pc, ex_target;
    
    assign clk = bp.clk;
    assign reset = bp.reset;
    assign id_is_branch = bp.id_is_branch;
    assign id_branch_type = bp.id_branch_type;
    assign id_pc = bp.id_pc;
    assign id_target = bp.id_target;
    assign ex_branched = bp.ex_branched;
    assign ex_pc = bp.ex_pc;
    assign ex_target = bp.ex_target;
    
    logic always_should_branch;
    BranchPredictor always_ibp(.*);
    AlwaysBranchPredictor always_bp(.bp(always_ibp));
    
    logic never_should_branch;
    BranchPredictor never_ibp(.*);
    NeverBranchPredictor never_bp(.bp(never_ibp));
    
    logic random_should_branch;
    BranchPredictor random_ibp(.*);
    RandomBranchPredictor random(.bp(random_ibp));
    
    logic tla_should_branch;
    BranchPredictor tla_ibp(.*);
    TwoLevelAdaptivePredictor tla(.bp(tla_ibp));
    
    logic tbs_should_branch;
    BranchPredictor tbs_ibp(.*);
    TwoBitSaturatedCounterPredictor tbs(.bp(tbs_ibp));
    
    always_comb case (selection)
        bp_random: 
            bp.should_branch = random_should_branch;
        bp_always: 
            bp.should_branch = always_should_branch;
        bp_never: 
            bp.should_branch = never_should_branch;
        bp_tla: 
            bp.should_branch = tla_should_branch;
        bp_tbs: 
            bp.should_branch = tbs_should_branch;
    endcase
    
endmodule
