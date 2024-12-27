//------------------------------------
// Project:   CPUC
// File name: cpuc_cmp.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: comperator
//--------------------------------------

`include "cpuc_macros.vh"

module cpuc_cmp
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]  data_in1,
    input logic [DATA_WIDTH-1:0]  data_in2,
    output logic [DATA_WIDTH-1:0] data_out

);
  
  generate;
    if(SIGNED_CMP == 1) begin
        assign data_out = ($signed(data_in1) > $signed(data_in2)) ? data_in1 : data_in2;  
    end else begin
        assign data_out = (data_in1 > data_in2) ? data_in1 : data_in2; 
    end
  endgenerate
        
endmodule