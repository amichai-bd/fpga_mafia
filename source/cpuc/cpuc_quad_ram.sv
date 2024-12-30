//------------------------------------
// Project:   CPUC
// File name: cpuc_quad_ram.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: quad port ram
//--------------------------------------
`include "cpuc_macros.vh"

module cpuc_quad_ram 
import cpuc_package::*;
#(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)
(
    input  logic                  clk,

    // Interface A
    input  logic [ADDR_WIDTH-1:0] address_a, 
    input  logic                  wren_a,
    input  logic [DATA_WIDTH-1:0] data_a,    
    output logic [DATA_WIDTH-1:0] q_a, 

    // Interface B
    input  logic [ADDR_WIDTH-1:0] address_b, 
    input  logic                  wren_b,
    input  logic [DATA_WIDTH-1:0] data_b,    
    output logic [DATA_WIDTH-1:0] q_b,

    // Interface C
    input  logic [ADDR_WIDTH-1:0] address_c, 
    input  logic                  wren_c,
    input  logic [DATA_WIDTH-1:0] data_c,    
    output logic [DATA_WIDTH-1:0] q_c, 

    // Interface D
    input  logic [ADDR_WIDTH-1:0] address_d, 
    input  logic                  wren_d,
    input  logic [DATA_WIDTH-1:0] data_d,    
    output logic [DATA_WIDTH-1:0] q_d       
);

    logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];
    logic [DATA_WIDTH-1:0] next_mem [0:MEM_SIZE-1];

    always_comb begin
        next_mem = mem;
        
        if (wren_a)
            next_mem[address_a] = data_a;
        
        if (wren_b)
            next_mem[address_b] = data_b;
        
        if (wren_c)
            next_mem[address_c] = data_c;
        
        if (wren_d)
            next_mem[address_d] = data_d;
    end

    `CPUC_DFF(mem, next_mem, clk)

    assign q_a = mem[address_a];
    assign q_b = mem[address_b];
    assign q_c = mem[address_c];
    assign q_d = mem[address_d];

endmodule
