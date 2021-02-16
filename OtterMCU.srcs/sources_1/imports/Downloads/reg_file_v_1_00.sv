`timescale 1ns / 1ps

module RegFile(
    input [31:0] wd,
    input clk, 
    input en,
    input [4:0] adr1,
    input [4:0] adr2,
    input [4:0] wa,
    output logic [31:0] rs1, 
    output logic [31:0] rs2
    );
    
    logic [31:0] reg_file [0:31];
    
    //- init registers to zero
    initial begin
        for (int i=0; i<32; i++)
            reg_file[i] = 0;
    end
    
    always_ff @(posedge clk) begin
        if (en && (wa != 0))
            reg_file[wa] <= wd; 
    end
    
    //- asynchronous reads
    always_comb 
        if (adr1 == 0) 
            rs1 = 32'b0;
        else if (adr1 == wa && en)
            rs1 = wd;
        else
            rs1 = reg_file[adr1];
    
    always_comb 
        if (adr2 == 0) 
            rs2 = 32'b0;
        else if (adr2 == wa && en)
            rs2 = wd;
        else
            rs2 = reg_file[adr2];
    
endmodule
