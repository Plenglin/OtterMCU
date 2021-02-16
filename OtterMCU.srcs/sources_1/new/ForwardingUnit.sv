`timescale 1ns / 1ps
import Types::*;

module ForwardingUnit(
    input [4:0] idex_adr,
    input [31:0] idex_data,
    
    input [4:0] exmem_wa,
    input [31:0] exmem_data,
    input exmem_we,
    
    input [4:0] memwb_wa,
    input [31:0] memwb_data,
    input memwb_we,
    
    output logic [31:0] alu_arg
    );
   
    fwdsrc_t fwd;
    
    always_comb 
        if (exmem_we & exmem_wa != 0 & idex_adr == exmem_wa) 
            fwd = fwdsrc_EXMEM;
        else if (memwb_we & memwb_wa != 0 & idex_adr == exmem_wa)
            fwd = fwdsrc_MEMWB;
        else
            fwd = fwdsrc_IDEX;
    
    always_comb case(fwd)
        fwdsrc_IDEX: alu_arg = idex_data;
        fwdsrc_EXMEM: alu_arg = exmem_data;
        fwdsrc_MEMWB: alu_arg = memwb_data; 
    endcase
        
endmodule
