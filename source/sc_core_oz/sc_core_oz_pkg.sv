
package sc_core_oz_pkg;

parameter DATA_WIDTH = 32;

typedef enum logic [3:0] {
    ADD = 4'b0000,
    SUB = 4'b1000,
    SLL = 4'b0001,
    SLT = 4'b0010,
    SLTU = 4'b0011,
    XOR = 4'b0100,
    SRL = 4'b0101,
    SRA = 4'b1101,
    OR = 4'b0110,
    AND = 4'b0111
} m_alu_op;


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
} m_opcode 


typedef enum logic [2:0] {
    U_TYPE = 3'b000 , 
    I_TYPE = 3'b001 ,  
    S_TYPE = 3'b010 ,     
    B_TYPE = 3'b011 , 
    J_TYPE = 3'b100 
} m_immediate ;

typedef struct packed {
    logic [31:0] reg_src1;
    logic [31:0] reg_src2;
    logic [31:0] imm;
    m_alu_op op;
} m_alu_ctrl;





endpackage