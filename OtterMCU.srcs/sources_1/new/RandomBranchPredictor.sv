module RandomBranchPredictor(
        BranchPredictor.Predictor bp
    );
    logic last_branch = 0;
    assign bp.should_branch = last_branch;
    
    always_ff @(posedge bp.clk) begin
        last_branch <= !last_branch;
    end
endmodule