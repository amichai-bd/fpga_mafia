include "macros.vh"

module ifu_prefetcher
import ifu_pkg::*;
(
    // Chip Signals
    input logic Clock,
    input logic Rst,

    // CPU Interface
    input logic [ADDR_WIDTH-1:0] cpu_reqAddrIn, // requested addr by cpu
    
    // Cache Interface
    input logic [ADDR_WIDTH-1:0] cache_miss_addr_in,  // Address causing a miss in the cache
    input logic cache_miss_valid_in,                  // Indicates if the cache miss is valid
    output logic [ADDR_WIDTH-1:0] prefetch_addr_out,  // Predicted address to prefetch
    output logic prefetch_addr_valid_out,             // Indicates if the prefetch address is valid

    // Memory Interface
    input logic mem_prefetch_ready_in                    // Indicates if memory can accept prefetch requests
    output logic [ADDR_WIDTH-1:0] mem_prefetch_addr_out, // Predicted address sent to memory
    output logic mem_prefetch_valid_out,                 // Indicates if the prefetch request is valid
);

    

///////////////////
// Logic Defines //
///////////////////









/////////////
// Assigns //
/////////////









///////////////////////////
// Always Comb Statement //
///////////////////////////








///////////////////////////
// Always_ff Statement ////
///////////////////////////




endmodule


