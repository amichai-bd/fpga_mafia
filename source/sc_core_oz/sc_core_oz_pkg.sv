
package sc_core_oz_pkg;

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


typedef struct packed {
    logic [31:0] reg_src1;
    logic [31:0] reg_src2;
    m_alu_op op;
} m_alu_ctrl;





endpackage