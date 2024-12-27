//------------------------------------
// Project:   CPUC
// File name: cpuc_mul.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: mul two number
//--------------------------------------

`include "cpuc_macros.vh"

module cpuc_mul
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]  data_in1,
    input logic [DATA_WIDTH-1:0]  data_in2,
    output logic [DATA_WIDTH-1:0] data_out

);
  
    assign data_out = data_in1 * data_in2; // TODO replace with multiplier
        
endmodule