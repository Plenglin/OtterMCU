module TwoLevelAdaptivePredictor(
        BranchPredictor.Predictor bp
    );
    logic[1:0] patternHistoryTable [0:3]; //index is the pattern, the value is the strongly/weakly branch/noBranch
    logic[1:0] history = 0;
    
    always_ff @(posedge bp.clk) begin
        if (bp.reset) begin
            patternHistoryTable[0] <= 'b10;
            patternHistoryTable[1] <= 'b10;
            patternHistoryTable[2] <= 'b10;
            patternHistoryTable[3] <= 'b10;            
        end if (bp.ex_is_branch) begin
            case(patternHistoryTable[history])
                'b00:
                    if (bp.ex_branched) begin
                        patternHistoryTable[history] <= 'b01;
                    end
                'b11:
                    if (bp.ex_branched != 0) begin
                        patternHistoryTable[history] <= 'b10;
                    end
                default: begin
                    patternHistoryTable[history] <= patternHistoryTable[history] + (bp.ex_branched ? 1 : -1);
                end
            endcase
        end
        
        history[1] <= {history[0], bp.ex_branched};
    end
    
    assign bp.should_branch = patternHistoryTable[history][1];

endmodule
