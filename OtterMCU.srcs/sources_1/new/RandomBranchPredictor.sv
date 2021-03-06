module RandomBranchPredictor(
        BranchPredictor.Predictor bp
    );
    logic [7:0] counter = 82;
    logic [7:0] next;
    assign bp.should_branch = counter[0];
    
    always_comb begin
        next = counter + 8'h6e;  // randomly chosen
        next = {  // funky swizzle for moar random
            next[1], 
            next[2], 
            next[6], 
            next[5], 
            next[0], 
            next[4], 
            next[7], 
            next[3]
        };
        next = next ^ 8'ha5;  // xor for even more random
    end
    
    always_ff @(posedge bp.clk) begin
        counter <= next;
    end
endmodule