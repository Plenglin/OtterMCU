module TwoBitSaturatedCounterPredictor(
        BranchPredictor.Predictor bp
    );
    logic[1:0] curState; // 0 - strong no branch, 1 - weak no branch, 2 - weak branch, 3 - strong branch
    
    initial begin
        curState = 'b10;
    end
    
    assign bp.should_branch = curState[1];
    
    always_ff @(posedge bp.clk) begin
        case(curState)
            'b00:
                if (bp.ex_branched) begin
                    curState = 'b01;
                end
            'b11:
                if (bp.ex_branched != 0) begin
                    curState = 'b10;
                end
            default: begin
                curState = curState - 1 + 2*bp.ex_branched;
            end
        endcase
    end
    
endmodule