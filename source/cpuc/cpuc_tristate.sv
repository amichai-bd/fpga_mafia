//------------------------------------
// Project:   CPUC
// File name: cpuc_tristate.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: mux
//--------------------------------------

`include "cpuc_macros.vh"


module cpuc_tristate
import cpuc_package::*;
(
    input logic                   en,
    input logic [DATA_WIDTH-1:0]  data_in,
    output logic [DATA_WIDTH-1:0] data_out
);

    assign data_out = (en==1'b1) ? data_in : {DATA_WIDTH{1'bz}};
    
endmodule