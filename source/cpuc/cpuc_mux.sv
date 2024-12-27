//------------------------------------
// Project:   CPUC
// File name: cpuc_mux.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: mux
//--------------------------------------

`include "cpuc_macros.vh"


module cpuc_mux
import cpuc_package::*;
(
    input logic                   ctrl,
    input logic [DATA_WIDTH-1:0]  data_in0,
    input logic [DATA_WIDTH-1:0]  data_in1,
    output logic [DATA_WIDTH-1:0] data_out
);

    assign data_out = (ctrl == 1'b0) ? data_in0 : data_in1;
    
endmodule