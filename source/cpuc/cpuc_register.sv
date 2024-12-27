//------------------------------------
// Project:   CPUC
// File name: cpuc_register.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: register
//--------------------------------------

`include "cpuc_macros.vh"


module cpuc_register
import cpuc_package::*;
(
    input logic                   clk,
    input logic                   rst,
    input logic [DATA_WIDTH-1:0]  data_in,  // inputs to all registers
    output logic [DATA_WIDTH-1:0] data_out  // output from all registers
);

    logic [DATA_WIDTH-1:0] register;

   `CPUC_RST_DFF(register, data_in, clk, rst)

    assign data_out = register;


endmodule