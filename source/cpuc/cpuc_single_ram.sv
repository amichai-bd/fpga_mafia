//------------------------------------
// Project:   CPUC
// File name: cpuc_single_ram.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: single port ram
//--------------------------------------
`include "cpuc_macros.vh"

module cpuc_single_ram
import cpuc_package::*;
(
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] address, // degined as A
    input  logic                  wren,
    input  logic [DATA_WIDTH-1:0] data,    // defined as V
    output logic [DATA_WIDTH-1:0] q        // defined as M
);

    logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    `CPUC_EN_DFF(mem[address], data , clk, wren)

    assign q = mem[address];

endmodule