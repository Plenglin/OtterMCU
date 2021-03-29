`timescale 1ns / 1ps

module NeverBranchPredictor(
        BranchPredictor.Predictor bp
    );
    assign bp.should_branch = 0;
endmodule
