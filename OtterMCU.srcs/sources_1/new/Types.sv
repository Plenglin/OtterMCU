package Types;

// Bits: <is branch> <should jump>
typedef enum logic [1:0] {
    predict_none = 2'b00,
    predict_jump = 2'b01,
    predict_nobr = 2'b10,
    predict_br = 2'b11
} br_predict_t;

// Bits: <is branch> <was correct> <should have jumped>
typedef enum logic [2:0] {
    confirm_nobr = 3'b110,
    confirm_br = 3'b111,
    rollback_br = 3'b100,
    rollback_nobr = 3'b101,
    ex_jalr = 3'b001,
    ex_normal = 3'b000
} br_certain_t;

typedef enum logic [4:0] {
    bp_random,
    bp_always,
    bp_never,
    bp_backwards,
    bp_past,
    bp_tla,
    bp_tbs
} branch_predictor_t;

typedef enum logic [6:0] {
    LUI      = 7'b0110111,
    AUIPC    = 7'b0010111,
    JAL      = 7'b1101111,
    JALR     = 7'b1100111,
    BRANCH   = 7'b1100011,
    LOAD     = 7'b0000011,
    STORE    = 7'b0100011,
    OP_IMM   = 7'b0010011,
    OP_RG3   = 7'b0110011, 
    OP_INT   = 7'b1110011 
} opcode_t;

typedef enum logic [3:0] {
    alufun_ADD        = 4'b0000,
    alufun_SUB        = 4'b1000,
    alufun_OR         = 4'b0110,
    alufun_AND        = 4'b0111,
    alufun_XOR        = 4'b0100,
    alufun_SRL        = 4'b0101,
    alufun_SLL        = 4'b0001,
    alufun_SRA        = 4'b1101,
    alufun_SLT        = 4'b0010,
    alufun_SLTU       = 4'b0011,
    alufun_LUI        = 4'b1001
} alufun_t;

typedef enum logic [2:0] {
    //BRANCH labels
    BEQ = 3'b000,
    BNE = 3'b001,
    BLT = 3'b100,
    BGE = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
} func3_t;    

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

typedef enum logic [1:0] {
    fwdsrc_IDEX = 0,
    fwdsrc_EXMEM = 1,
    fwdsrc_MEMWB = 2
} fwdsrc_t;

typedef enum logic {
    wbfwd_LOAD = 0,
    wbfwd_ALU = 1
} wbfwd_t;

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

typedef struct packed {
    logic write;
    logic read;
    logic sign;
    logic [31:0] rs2;
    logic [4:0] rs2_adr;
    logic [1:0] size;
} st_MEM_t;

typedef struct packed {
    logic rf_wr_en;
    regwr_t rf_wr_sel;
    logic [4:0] wa;
} st_WB_t;

typedef struct packed {
    logic [31:0] pc;
} IFID_t;

typedef struct packed {
    logic [31:0] pc;
    alufun_t alu_fun;
    logic [4:0] alu_a_adr;
    logic [4:0] alu_b_adr;
    logic [31:0] alu_a;
    logic [31:0] alu_b;
    logic [31:0] jump_target;
    logic [31:0] i_imm;
    br_predict_t branch_status;
    opcode_t opcode;
    func3_t func3;
    st_MEM_t mem;
    st_WB_t wb;
} IDEX_t;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] alu_result;
    st_MEM_t mem;
    st_WB_t wb;
} EXMEM_t;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] alu_result;
    st_WB_t wb;
} MEMWB_t;

typedef struct packed {
    logic [31:0] 
        correct_br, 
        correct_nobr, 
        wrong_br, 
        wrong_nobr;
} branch_perf;

typedef struct packed {
    branch_perf branch;
} performance_t;

endpackage