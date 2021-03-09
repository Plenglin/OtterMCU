module TwoLevelAdaptivePredictor(
        BranchPredictor.Predictor bp
    );
    logic[1:0][1:0] patternHistoryTable; //index is the pattern, the value is the strongly/weakly branch/noBranch
    logic[1:0] history;
        
    initial begin
        patternHistoryTable['b00] = 'b10;
        patternHistoryTable['b01] = 'b10;
        patternHistoryTable['b10] = 'b10;
        patternHistoryTable['b11] = 'b10;
        history = 'b00;
        bp.branch = 'b0;
    end
    
    always_ff @(posedge bp.clk) begin
        case(patternHistoryTable[history])
            'b00:
                if (bp.ex_branched) begin
                    patternHistoryTable[history] = 'b01;
                end
            'b11:
                if (bp.ex_branched != 0) begin
                    patternHistoryTable[history] = 'b10;
                end
            default: begin
                patternHistoryTable[history] = patternHistoryTable[history] - 1 + 2*bp.ex_branched;
            end
        endcase
        bp.branch = patternHistoryTable[history][1];
        history[1] = history[0];
        history[0] = bp.ex_branched;
    end

endmodule
