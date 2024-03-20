package mini_core_rrv_pkg;

parameter I_MEM_SIZE   = 'h1_0000; 
parameter I_MEM_OFFSET = 'h0_0000;
parameter I_MEM_ADRS_MSB = 15;

parameter RF_NUM_MSB = 31;

typedef struct packed{
    logic SelNextPcAluOutQ101H;
} t_ctrl_if;

typedef struct packed {
    logic [4:0] RegSrc1Q101H;
    logic [4:0] RegSrc2Q101H;
    logic [4:0] RegDstQ102H;
    logic       RegWrEnQ102H;
} t_ctrl_rf;

typedef enum logic[3:0]{
    ADD  = 4'b0000 ,
    SUB  = 4'b1000 ,
    SLT  = 4'b0010 ,
    SLTU = 4'b0011 ,
    SLL  = 4'b0001 , 
    SRL  = 4'b0101 ,
    SRA  = 4'b1101 ,
    XOR  = 4'b0100 ,
    OR   = 4'b0110 ,
    AND  = 4'b0111 
} t_alu_op;

typedef enum logic [2:0] {
   BEQ  = 3'b000 ,
   BNE  = 3'b001 ,
   BLT  = 3'b100 ,
   BGE  = 3'b101 ,
   BLTU = 3'b110 ,
   BGEU = 3'b111
} t_branch_type;

typedef struct packed{
    t_alu_op      AluOpQ101H;
    t_branch_type BranchOpQ101H;
    logic  [31:0] AluIn1Q101H;
    logic  [31:0] AluIn2Q101H;
} t_ctrl_alu;

typedef enum logic [1:0] {
    WB_DMEM = 2'b00 , 
    WB_ALU =  2'b01 ,  
    WB_PC4 =  2'b10      
} t_e_sel_wb;

typedef struct packed {
    logic [3:0] ByteEnQ105H;
    logic [3:0] SignExtQ105H;
    t_e_sel_wb  e_SelWrBackQ105H;
} t_ctrl_wb;


typedef enum logic [6:0] {
   LUI    = 7'b0110111 ,
   AUIPC  = 7'b0010111 ,
   JAL    = 7'b1101111 ,
   JALR   = 7'b1100111 ,
   BRANCH = 7'b1100011 ,
   LOAD   = 7'b0000011 ,
   STORE  = 7'b0100011 ,
   I_OP   = 7'b0010011 ,
   R_OP   = 7'b0110011 ,
   FENCE  = 7'b0001111 ,
   SYSCAL = 7'b1110011
} t_opcode ;

typedef struct packed{
    logic [4:0]    RegSrc1;
    logic [4:0]    RegSrc2;
    logic [4:0]    RegDst;
    logic          RegWrEn;
    t_alu_op       AluOp;
    logic [31:0]   ImmediateQ101H; 

} t_mini_core_rrv_ctrl;

endpackage