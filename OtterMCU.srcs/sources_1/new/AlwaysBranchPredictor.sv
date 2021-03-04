`timescale 1ns / 1ps

module AlwaysBranchPredictor(
        BranchPredictor.Predictor bp
    );
    assign bp.should_branch = 1;
endmodule
