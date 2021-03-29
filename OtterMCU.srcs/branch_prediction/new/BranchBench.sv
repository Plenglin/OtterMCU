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
    branch_predictor_t bp_selection;
    performance_t perf;
    OTTER_MCU mcu(
        .bp_selection(bp_selection),
        .RESET       (reset),
        .CLK         (clk),
        .IOBUS_IN    (0),
        .IOBUS_OUT   (iobus_out), 
        .IOBUS_ADDR  (iobus_addr), 
        .IOBUS_WR    (iobus_wr),
        .performance(perf)
    );
    
    logic done;
    assign done = (iobus_addr == 32'h10001000 & iobus_out == 1);

    string progname, predictorname;
    
    int start, duration;
    task run_simulation(); begin
        start = $time;
        reset = 1;
        #4;
        reset = 0;
        
        while (!done) #1;
        
        duration = $time - start; 
        $display(
            "%s\t%s\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d", 
            progname, 
            predictorname, 
            duration,
            perf.branch.correct_br,
            perf.branch.correct_nobr,
            perf.branch.wrong_br,
            perf.branch.wrong_nobr,
            perf.branch.flushes
        );
    end endtask
    
    string programs[] = '{
        "matmul.mem",
        "quicksort.mem",
        "testall.mem"
    };
    
    task run_programs(); begin
        for (int j = 0; j < $size(programs); j++) begin
            progname = programs[j];
            mcu.load_memory(progname);
            run_simulation();
        end
    end endtask
    
    initial begin
        $display("program\tpredictor\tduration\tcb\tcnb\twb\twnb\tflushes");
        
        predictorname = "always";
        bp_selection = bp_always;
        run_programs();
        
        predictorname = "never";
        bp_selection = bp_never;
        run_programs();
        
        predictorname = "random";
        bp_selection = bp_random;
        run_programs();
        
        predictorname = "backwards";
        bp_selection = bp_backwards;
        run_programs();
        
        predictorname = "past";
        bp_selection = bp_past;
        run_programs();
        
        predictorname = "twobit";
        bp_selection = bp_twobit;
        run_programs();
        
        predictorname = "2ladaptive";
        bp_selection = bp_tla;
        run_programs();
        
        $finish();
    end
endmodule
