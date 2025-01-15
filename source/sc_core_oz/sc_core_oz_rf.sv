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
module sc_core_oz_rf
import sc_core_oz_pkg::*;
(
    input logic clk,
    input logic rst,
    input logic SelRegWrPc,
    input logic [31:0] WrBackData,
    input logic  [31:0] PcPlus4,
    input  logic [31:0] Instruction,
    input  logic               CtrlRegWrEn,
    output logic [31:0]        RegRdData1, 
    output logic [31:0]        RegRdData2 
);
logic [31:0] Register [31:1];
m_opcode opcode;
logic [2:0] func3;
logic [6:0] func7;
logic [4:0]         RegSrc1, RegSrc2, RegDst;
logic CtrlAluOp;
t_immediate SelImmType;
assign opcode = m_opcode'(instruction[6:0]);
assign func3 = instruction[14:12];
assign func7 = instruction[31:25];

always_comb begin
     unique casez ({Funct3, Funct7, Opcode})
    //-----LUI type-------
   // {3'b???, 7'b???????, LUI } : CtrlAluOp = IN_2;//LUI
    //-----R type-------
    {3'b000, 7'b0000000, R_OP} : CtrlAluOp = ADD; //ADD
    {3'b000, 7'b0100000, R_OP} : CtrlAluOp = SUB; //SUB
    {3'b001, 7'b0000000, R_OP} : CtrlAluOp = SLL; //SLL
    {3'b010, 7'b0000000, R_OP} : CtrlAluOp = SLT; //SLT
    {3'b011, 7'b0000000, R_OP} : CtrlAluOp = SLTU;//SLTU
    {3'b100, 7'b0000000, R_OP} : CtrlAluOp = XOR; //XOR
    {3'b101, 7'b0000000, R_OP} : CtrlAluOp = SRL; //SRL
    {3'b101, 7'b0100000, R_OP} : CtrlAluOp = SRA; //SRA
    {3'b110, 7'b0000000, R_OP} : CtrlAluOp = OR;  //OR
    {3'b111, 7'b0000000, R_OP} : CtrlAluOp = AND; //AND
    //-----I type-------
    {3'b000, 7'b???????, I_OP} : CtrlAluOp = ADD; //ADDI
    {3'b010, 7'b???????, I_OP} : CtrlAluOp = SLT; //SLTI
    {3'b011, 7'b???????, I_OP} : CtrlAluOp = SLTU;//SLTUI
    {3'b100, 7'b???????, I_OP} : CtrlAluOp = XOR; //XORI
    {3'b110, 7'b???????, I_OP} : CtrlAluOp = OR;  //ORI
    {3'b111, 7'b???????, I_OP} : CtrlAluOp = AND; //ANDI
    {3'b001, 7'b0000000, I_OP} : CtrlAluOp = SLL; //SLLI
    {3'b101, 7'b0000000, I_OP} : CtrlAluOp = SRL; //SRLI
    {3'b101, 7'b0100000, I_OP} : CtrlAluOp = SRA; //SRAI
    //-----Other-------
    default                    : CtrlAluOp = ADD; //AUIPC || JAL || JALR || BRANCH || LOAD || STORE
    endcase
end
//  Immediate Generator
always_comb begin
  unique casez (Opcode)    //mux
    JALR, I_OP, LOAD : SelImmType = I_TYPE;
    LUI, AUIPC       : SelImmType = U_TYPE;
    JAL              : SelImmType = J_TYPE;
    BRANCH           : SelImmType = B_TYPE;
    STORE            : SelImmType = S_TYPE;
    default          : SelImmType = I_TYPE;
  endcase
  unique casez (SelImmType)    //mux
    U_TYPE : Immediate = {     Instruction[31:12], 12'b0 } ;                                                            //U_Immediate;
    I_TYPE : Immediate = { {20{Instruction[31]}} , Instruction[31:20] };                                                //I_Immediate;
    S_TYPE : Immediate = { {20{Instruction[31]}} , Instruction[31:25] , Instruction[11:7]  };                           //S_Immediate;
    B_TYPE : Immediate = { {20{Instruction[31]}} , Instruction[7]     , Instruction[30:25] , Instruction[11:8]  , 1'b0};//B_Immediate;
    J_TYPE : Immediate = { {12{Instruction[31]}} , Instruction[19:12] , Instruction[20]    , Instruction[30:21] , 1'b0};//J_Immediate;
    default: Immediate = {     Instruction[31:12], 12'b0 };                                                             //U_Immediate;
  endcase
end

assign RegDst  = Instruction[11:7];
assign RegSrc1 = Instruction[19:15];
assign RegSrc2 = Instruction[24:20];
// --- Select what Write to register file --------
assign RegWrData = SelRegWrPc ? PcPlus4 : WrBackData;
//---- The Register File  ------
`MAFIA_EN_DFF(Register[RegDst] , RegWrData , Clk , (CtrlRegWrEn && (RegDst!=5'b0)))
// --- read Register File --------
assign RegRdData1 = (RegSrc1==5'b0) ? 32'b0 : Register[RegSrc1];
assign RegRdData2 = (RegSrc2==5'b0) ? 32'b0 : Register[RegSrc2];


logic [31:0] rf [30:0];   //register 0 has the value 0

endmodule