module PastBranchPredictor(
        BranchPredictor.Predictor bp
    );
    typedef struct packed{
        logic beq, bne, blt, bge, bltu, bgeu;
    } decisions;
    
    decisions bd = decisions'{
        beq: 1,
        bne: 1,
        blt: 1,
        bge: 1,
        bltu: 1,
        bgeu: 1
    };
    
    //setting if it should branch in decode phase
    always_comb case(bp.id_branch_type)
        BEQ:    bp.should_branch = bd.beq;
        BNE:    bp.should_branch = bd.bne;
        BLT:    bp.should_branch = bd.blt;
        BGE:    bp.should_branch = bd.bge;
        BLTU:   bp.should_branch = bd.bltu;
        BGEU:   bp.should_branch = bd.bgeu;
        default: bp.should_branch = 0;
    endcase

    //changing which opcodes should branch or not depending on if the execute phase branched
    always_ff @(posedge bp.clk) begin
        if (bp.ex_is_branch) begin
            case(bp.ex_branch_type)
                BEQ: 
                    bd.beq <= bp.ex_branched;
                BNE: 
                    bd.bne <= bp.ex_branched;
                BLT: 
                    bd.blt <= bp.ex_branched;
                BGE: 
                    bd.bge <= bp.ex_branched;
                BLTU: 
                    bd.bltu <= bp.ex_branched;
                BGEU: 
                    bd.bgeu <= bp.ex_branched;
                default: 
                    bd.bgeu <= 0;
            endcase
        end
    end
endmodule
