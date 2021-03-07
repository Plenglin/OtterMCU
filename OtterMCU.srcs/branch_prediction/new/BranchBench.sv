`timescale 1ns / 1ps

module BranchBench;
    logic clk = 0;
    always begin
        clk = 1;
        #1;
        clk = 0;
        #1;
    end
    
    logic reset, iobus_wr;
    logic [31:0] iobus_out, iobus_addr;
    BranchPredictor predictor();
    OTTER_MCU mcu(
        .RESET       (reset),
        .CLK         (clk),
        .IOBUS_IN    (0),
        .IOBUS_OUT   (iobus_out), 
        .IOBUS_ADDR  (iobus_addr), 
        .IOBUS_WR    (iobus_wr)
    );
    
    logic done;
    assign done = (iobus_wr & iobus_addr == 32'h10001000 & iobus_out == 1);

    string progname, predictorname;
    
    int start, duration;
    task run_simulation(); begin
        start = $time;
        reset = 1;
        #4;
        reset = 0;
        
        while (!done);
        
        duration = $time - start; 
        $display("%s,%s,%s", progname, predictorname, duration);
    end endtask
    
    string predictors[] = '{
        "always",
        "never",
        "random"
    };
    
    string programs[] = '{
        "matmul.mem"
    };
    
    AlwaysPredictor always_pred();
    NeverPredictor never_pred();
    RandomPredictor random_pred();
    
    initial begin
        for (int i = 0; i < $size(predictors); i++) begin
            predictorname = predictors[i];
            case (predictorname)
                "random": 
                    assign predictor.Predictor = random_pred.predictor;
                "always": 
                    assign predictor.Predictor = always_pred.predictor;
                "never": 
                    assign predictor.Predictor = never_pred.predictor; 
            endcase
            
            for (int j = 0; j < $size(programs); j++) begin
                progname = programs[i];
                mcu.load_memory(progname);
                run_simulation();
            end
        end
    end
endmodule
