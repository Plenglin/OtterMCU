`timescale 1ns / 1ps

module PipelineRegister#(parameter SIZE=1)(
        input clk,
        input flush = 0,
        input hold = 0,
        input [SIZE-1:0] in_data, 
        output logic [SIZE-1:0] out_data = SIZE'(0)
    );
    always_ff @(posedge clk) begin
        if (flush) 
            out_data <= SIZE'(0);
        else if (!hold)
            out_data <= in_data;
    end
endmodule
