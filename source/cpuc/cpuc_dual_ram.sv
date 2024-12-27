//------------------------------------
// Project:   CPUC
// File name: cpuc_dual_ram.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: dualport ram
//--------------------------------------
`include "cpuc_macros.vh"

module cpuc_dual_ram
import cpuc_package::*;
(
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] address_a, 
    input  logic                  wren_a,
    input  logic [DATA_WIDTH-1:0] data_a,    
    output logic [DATA_WIDTH-1:0] q_a, 

    // interface b
    input  logic [ADDR_WIDTH-1:0] address_b, 
    input  logic                  wren_b,
    input  logic [DATA_WIDTH-1:0] data_b,    
    output logic [DATA_WIDTH-1:0] q_b       
);

    logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];
    logic [DATA_WIDTH-1:0] next_mem [0:MEM_SIZE-1];

    always_comb begin
        next_mem = mem;
        if(wren_a)
            next_mem[address_a] = data_a;
        if(wren_b)
            next_mem[address_b] = data_b;
    end

    `CPUC_DFF(mem, next_mem, clk)

    assign q_a = mem[address_a];
    assign q_b = mem[address_b];

endmodule