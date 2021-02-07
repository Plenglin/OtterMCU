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

typedef enum logic [2:0] {
    pcsrc_NEXT = 0,
    pcsrc_JALR = 1,
    pcsrc_BRANCH = 2,
    pcsrc_JAL = 3,
    pcsrc_MTVEC = 4
} pcsrc_t;

typedef enum logic [1:0] {
    regwr_PCNEXT = 0,
    regwr_CSR = 1,
    regwr_MEM = 2,
    regwr_ALU = 3
} regwr_t;

typedef enum logic {
    alusrc_a_RS1 = 0,
    alusrc_a_UIMM = 1
} alusrcA_t;

typedef enum logic [1:0] {
    alusrc_b_RS2 = 0,
    alusrc_b_IIMM = 1,
    alusrc_b_SIMM = 2,
    alusrc_b_PC = 3
} alusrcB_t;

typedef struct packed{
    logic write;
    logic read;
    logic sign;
    logic [31:0] rs2;
    logic [1:0] size;
} st_MEM_t;

typedef struct packed{
    logic rf_wr_en;
    logic [1:0] rf_wr_sel;
    logic [4:0] wa;
} st_WB_t;

typedef struct packed{
    logic [31:0] pc;
} IFID_t;

typedef struct packed{
    logic [31:0] pc;
    logic [3:0] alu_fun;
    logic [31:0] alu_a;
    logic [31:0] alu_b;
    logic [31:0] j_imm;
    logic [31:0] b_imm;
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