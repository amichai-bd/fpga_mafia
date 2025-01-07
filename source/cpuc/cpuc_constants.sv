//---------------------------------------------
// Project:   CPUC
// File name: cpuc_constants 
// Date:      26.12.24
// Author:     
//---------------------------------------------
// Description: cpuc_constants
//---------------------------------------------
`include "cpuc_macros.vh"

module cpuc_constants
import cpuc_package::*;
(
    output logic [DATA_WIDTH-1:0] const0,
    output logic [DATA_WIDTH-1:0] const1,
    output logic [DATA_WIDTH-1:0] const2,
    output logic [DATA_WIDTH-1:0] const3

);

assign const0 = 'h1;
assign const1 = 'h2;
assign const2 = 'h3;
assign const3 = 'h4;

endmodule