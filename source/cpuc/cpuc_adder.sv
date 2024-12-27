//------------------------------------
// Project:   CPUC
// File name: cpuc_adder.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: adding two number
//--------------------------------------

`include "cpuc_macros.vh"

module cpuc_adder
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]  data_in1,
    input logic [DATA_WIDTH-1:0]  data_in2,
    output logic [DATA_WIDTH-1:0] data_out

);
  
    assign data_out = data_in1 + data_in2;
        
endmodule