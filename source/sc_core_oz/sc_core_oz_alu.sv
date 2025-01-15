//-----------------------------------------------------------------------------
// Title            : single cycle core design
// Project          : 
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Obaida and Zena 
// Code Owner       : 
// Created          : 01/2025
//-----------------------------------------------------------------------------
// Description :
// This is the top level of the single cycle core design.
// The core is a 32 bit RISC-V core.
// compatible with the RV32I base instruction set.
// Fetch, Decode, Execute, Memory, WriteBack all in one cycle.
// The PC (program counter) is the synchronous element in the core 
//-----------------------------------------------------------------------------
`include "macros.vh"





module sc_core_oz_alu 
import sc_core_oz_pkg::*;
(   
    input logic clk,
    input logic rst,
    input var m_alu_ctrl alu_ctrl,
    input logic [4:0] reg_dest,
    input logic [31:0] Instruction,
    output logic [31:0] result

);

logic [31:0]        Immediate;
logic [2:0]         Funct3;
logic [6:0]         Funct7;
m_opcode            Opcode;
m_immediate         immType;



///////////////////////////////////////////
//         Decode                        //
// 

assign Opcode = m_opcode'(Instruction[6:0]);
assign Funct3           = Instruction[14:12];
assign Funct7           = Instruction[31:25];





always_comb begin: alu_logic 
    case (alu_ctrl.op)
        ADD: result = alu_ctrl.reg_src1 + alu_ctrl.reg_src2;                                            //addition 
        SUB: result = alu_ctrl.reg_src1 - alu_ctrl.reg_src2;                                            //subtraction
        SLL: result = alu_ctrl.reg_src1 << alu_ctrl.reg_src2;                                           //logical left shift
        SLT: result = ($signed(alu_ctrl.reg_src1) < $signed(alu_ctrl.reg_src2)) ? 32'd1 : 32'd0;        //set less than (signed)
        SLTU: result = (alu_ctrl.reg_src1 < alu_ctrl.reg_src2) ? 32'd1 : 32'd0;                         // set less than unsigned
        XOR: result = alu_ctrl.reg_src1 ^ alu_ctrl.reg_src2;                                            //bitwise xor (exclusive or)
        SRL: result = alu_ctrl.reg_src1 >> alu_ctrl.reg_src2;                                           //logical right shift
        SRA: result = ($signed(alu_ctrl.reg_src1) >>> $signed(alu_ctrl.reg_src2));                      //arithmetic right shift
        OR: result = alu_ctrl.reg_src1 | alu_ctrl.reg_src2;                                             //bitwise OR
        AND: result = alu_ctrl.reg_src1 & alu_ctrl.reg_src2;                                            //bitwise AND
        default: result = 32'b0;                                                                        //default case to handle undefined operations 
    endcase

end
endmodule



