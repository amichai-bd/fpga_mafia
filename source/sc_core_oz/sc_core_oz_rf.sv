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
    input logic [31:0] rd_reg_data,
    input logic [4:0] rd_reg_address
);
logic [31:0] rf [30:0];   //register 0 has the value 0

endmodule