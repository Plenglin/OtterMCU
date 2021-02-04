`ifndef ___TYPES_SV___
`define ___TYPES_SV___

typedef enum logic [6:0] {
    LUI      = 7'b0110111,
    AUIPC    = 7'b0010111,
    JAL      = 7'b1101111,
    JALR     = 7'b1100111,
    BRANCH   = 7'b1100011,
    LOAD     = 7'b0000011,
    STORE    = 7'b0100011,
    OP_IMM   = 7'b0010011,
    OP       = 7'b0110011,
    SYSTEM   = 7'b1110011
} opcode_t;

typedef struct packed{
    logic something;  // TODO
} st_EX_t;

typedef struct packed{
    logic alu_src;
    logic memWrite;
    logic [1:0] size;
    logic [3:0] alu_fun;
    logic [31:0] rs2;
} st_MEM_t;

typedef struct packed{
    logic alu_src;
    logic [3:0] alu_fun;
    logic [1:0] rf_wr_sel;
    logic [4:0] wa;
    logic we;
} st_WB_t;

typedef struct packed{
    logic [31:0] pc;
} IFID_t;

typedef struct packed{
    logic [31:0] pc;
    logic [3:0] alu_fun;
    logic [31:0] alu_a;
    logic [31:0] alu_b;
    st_EX_t ex;
    st_MEM_t mem;
    st_WB_t wb;
} IDEX_t;

typedef struct packed{
    logic [31:0] pc;
    logic [31:0] alu_result;
    st_MEM_t mem;
    st_WB_t wb;
} EXMEM_t;

typedef struct packed{
    logic [31:0] pc;
    logic [31:0] dout;
    logic [31:0] alu_result;
    st_WB_t wb;
} MEMWB_t;

`endif