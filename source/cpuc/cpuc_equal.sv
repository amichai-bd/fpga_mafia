//------------------------------------
// Project:   CPUC
// File name: cpuc_equal.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: is_equal
//--------------------------------------

`include "cpuc_macros.vh"

module cpuc_equal
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]  data_in1,
    input logic [DATA_WIDTH-1:0]  data_in2,
    output logic [DATA_WIDTH-1:0] data_out

);
  
    assign data_out = (data_in1 == data_in2) ? {DATA_WIDTH{1'b1}} : '0;
        
endmodule