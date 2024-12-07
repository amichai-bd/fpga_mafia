//-----------------------------------------------------------------------------
// Title            : instruction memory
// Project          : IFU - instruction getch unit
//-----------------------------------------------------------------------------
// File             : i_mem.sv
// Original Author  : 
// Code Owner       : 
// Adviser          : 
// Created          : 11/2024
//-----------------------------------------------------------------------------
// Description      : single port data_width RAM memory
//-----------------------------------------------------------------------------
`include "macros.vh"

module i_mem #(parameter DATA_WIDTH = 128, parameter ADRS_WIDTH = 32)
(
    input  logic                  clock    ,
    input  logic [ADRS_WIDTH-1:4] address  , 
    input  logic                  wren     ,
    input  logic [DATA_WIDTH-1:0] data     ,
    output logic [DATA_WIDTH-1:0] q        
);
    parameter MEM_SIZE = 4096; // 64Kb as defined in the linker. Each address has 16bytes. TODO - parametrize  

    logic [DATA_WIDTH-1:0] mem [MEM_SIZE-1:0];
    logic [DATA_WIDTH-1:0] pre_q;

    // writing
    `MAFIA_EN_DFF(mem[address] ,data, clock, wren)

    // reading
    assign pre_q = mem[address];
    `MAFIA_DFF(q, pre_q, clock) // adding 1 latency for read

    
endmodule