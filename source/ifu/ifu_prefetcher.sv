`include "macros.vh"

module ifu_prefetcher
import ifu_pkg::*;
(
    // Chip Signals
    input logic Clock,
    input logic Rst,

    // CPU Interface
    input logic [ADDR_WIDTH-1:0] cpu_reqAddrIn, // requested addr by cpu
    
    input logic [TAG_WIDTH-1:0] mem_rspTagIn, // tag of the line provided by response of the memory
    input logic mem_rspInsLineValidIn, // the line is ready in the response and can be read by the cache

    // Memory Interface
    output logic [TAG_WIDTH - 1:0] mem_reqTagOut, // Predicted address sent to memory
    output logic mem_reqTagValidOut             // Indicates if the prefetch request is valid
);

    
///////////////////
// Logic Defines //
///////////////////
logic [TAG_WIDTH - 1 : 0] cpu_reqTagIn;
logic mem_reqLineReady;

/////////////
// Assigns //
/////////////
assign cpu_reqTagIn = cpu_reqAddrIn[ADDR_WIDTH - 1 : OFFSET_WIDTH];
assign mem_reqTagOut = cpu_reqTagIn + 1;
assign mem_reqLineReady = mem_rspTagIn == mem_reqTagOut  &&  mem_rspInsLineValidIn;

///////////////////////////
// Always Comb Statement //
///////////////////////////
always_comb begin

    if (mem_reqLineReady) begin   // if the memory supplied us with the prefetched line
        mem_reqTagValidOut = !VALID;
    end else begin
        mem_reqTagValidOut = VALID;
    end

end


///////////////////////////
// Always_ff Statement ////
///////////////////////////


endmodule


