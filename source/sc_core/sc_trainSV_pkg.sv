`ifndef SC_CORE_PKG_SV
`define SC_CORE_PKG_SV
package sc_core_train_pkg;
    
`include "common_pkg.vh"

typedef enum logic [3:0]{
    ADD = 4'b0000;
    SUB = 4'b0001;
    SLL = 4'b0010;
    SLT = 4'b0011;
    SLTU = 4'b0100;
    XOR = 4'b0101;
    SRL = 4'b0110;
    SRA = 4'b0111;
    OR = 4'b1000;
    AND = 4'b1001;
    IN_2 = 4'b1010;
}t_alu_op_train;

typedef enum logic [2:0]{
    BEQ = 3'b000;
    BNE = 3'b001;
    BLT = 3'b010;
    BGE = 3'b011;
    BLTU = 3'b100;
    BGEU = 3'b101;
}t_branch_type_train;

typedef enum logic [6:0]{
    LUI = 7'b0110111;
    AUIPC = 7'b0010111;
    JAL = 7'b1101111;
    JALR = 7'b1100111;
    BRANCH = 7'b1100011;
    LOAD = 7'b0000011;
    STORE = 7'b0100011;
    I_TYPE = 7'0010011;
    R_TYPE = 7'0110011;
    FENCE = 7'0001111;
    SYSCALL = 7'1110011;
}t_opcode_train;

typedef enum logic [2:0]{
    R_TYPE = 3'b000;
    I_TYPE = 3'b001;
    S_TYPE = 3'b010;
    B_TYPE = 3'b011;
    U_TYPE = 3'b100;
    J_TYPE = 3'b101;
}t_inst_type_train;

