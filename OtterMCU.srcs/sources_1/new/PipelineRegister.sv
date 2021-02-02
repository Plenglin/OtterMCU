`timescale 1ns / 1ps

module PipelineRegister#(parameter SIZE=1)(
        input clk,
        input flush = 0,
        input hold = 0,
        input [SIZE-1:0] flush_data = 0,
        output [SIZE-1:0] in_data, 
        output logic [SIZE-1:0] out_data
    );
    always_ff @(posedge clk) begin
        if (flush) 
            out_data <= flush_data;
        else if (hold)
            out_data <= out_data;
        else 
            out_data <= in_data;
    end
endmodule
