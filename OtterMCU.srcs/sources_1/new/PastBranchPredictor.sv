module PastBranchPredictor(
        BranchPredictor.Predictor bp
    );
    typedef struct packed{
        logic beq, bne, blt, bge, bltu, bgeu;
        } decisions;
    
    logic prevDecision;
    decisions bd;
    
    initial begin
        prevDecision = 0;
        bd.beq = 1; bd.bne = 1; bd.blt = 1;
        bd.bge = 1; bd.bltu = 1; bd.bgeu = 1;
    end
    
    always_comb begin
        bp.should_branch = 0;
        //setting if it should branch in decode phase
        case(bp.id_branch_type)
            BEQ:    bp.should_branch = bd.beq;
            BNE:    bp.should_branch = bd.bne;
            BLT:    bp.should_branch = bd.blt;
            BGE:    bp.should_branch = bd.bge;
            BLTU:   bp.should_branch = bd.bltu;
            BGEU:   bp.should_branch = bd.bgeu;
            default: bp.should_branch = 0;
        endcase
        //changing which opcodes should branch or not depending on if the execute phase branched
        case(bp.ex_branch_type)
            BEQ:    if(bp.ex_branched != bd.beq) begin
                        bd.beq = !bd.beq;
                    end
            BNE:    if(bp.ex_branched != bd.bne) begin
                        bd.bne = !bd.bne;
                    end
            BLT:    if(bp.ex_branched != bd.blt) begin
                        bd.blt = !bd.blt;
                    end
            BGE:    if(bp.ex_branched != bd.bge) begin
                        bd.bge = !bd.bge;
                    end
            BLTU:   if(bp.ex_branched != bd.bltu) begin
                        bd.bltu = !bd.bltu;
                    end
            BGEU:   if(bp.ex_branched != bd.bgeu) begin
                        bd.bgeu = !bd.bgeu;
                    end
            default: begin end
        endcase
    end
endmodule
