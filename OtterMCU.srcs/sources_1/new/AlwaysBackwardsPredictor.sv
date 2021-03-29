`timescale 1ns / 1ps

module AlwaysBackwardsPredictor(
        BranchPredictor.Predictor bp
    );
    
    assign bp.should_branch = (bp.id_target <= bp.id_pc);
endmodule
