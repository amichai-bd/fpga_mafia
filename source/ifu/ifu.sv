`include "macros.vh"

module ifu
import ifu_pkg::*;
(
    // Chip Signals
    input logic Clock,
    input logic Rst,

    // CPU Interface
    input logic [ADDR_WIDTH-1:0] cpu_reqAddrIn,         // Address requested by the CPU
    output logic [ADDR_WIDTH-1:0] cpu_rspAddrOut,       // Address of the line in the response to CPU 
    output logic [LINE_WIDTH-1:0] cpu_rspInsLineOut,    // Instruction line in the response to CPU
    output logic cpu_rspInsLineValidOut,                // Indicates if the response is valid

    // Memory Interface
    input logic [TAG_WIDTH-1:0] mem_rspTagIn,       // Tag of the line provided by memory
    input logic [LINE_WIDTH-1:0] mem_rspInsLineIn,  // Line data provided by memory
    input logic mem_rspInsLineValidIn,              // Valid signal for memory response
    output logic [ADDR_WIDTH-1:0] mem_reqTagOut,    // Indicates if memory is ready for requests
    output logic mem_reqTagValidOut                    // Indicates if a memory request is valid
);


///////////////////
// Logic Defines //
///////////////////
// data insertion
logic insertionOnMiss;
logic insertionOnPrefetch;
logic p_reqSent;

// cache signals
logic [TAG_WIDTH - 1: 0] c_mem_reqTagOut;
logic c_mem_reqTagValidOut;

// prefetcher signals
logic [TAG_WIDTH - 1: 0] p_mem_reqTagOut;
logic p_mem_reqTagValidOut;

// cache <-> prefetcher 
logic                    c2p_rspTagValid; 
logic                    c2p_rspTagStatus;
logic [TAG_WIDTH - 1: 0] c2p_rspTag;
logic                    p2c_reqTagValid;
logic [TAG_WIDTH - 1: 0] p2c_reqTag;

///////////
// Cache //
///////////
ifu_cache ifu_cache (
    .Clock(Clock),                                          // Input
    .Rst(Rst),                                              // Input

    // Prefetcher Interface
    .pref_reqTagValidIn(p2c_reqTag),                        // Input
    .pref_reqTagIn(p2c_reqTagValid),                        // Input
    .pref_rspTagValidOut(c2p_rspTagValid),                  // Output
    .pref_rspTagStatusOut(c2p_rspTagStatus),                // Output
    .pref_rspTagOut(p2c_reqTag),                            // Output

    // CPU Interface
    .cpu_reqAddrIn(cpu_reqAddrIn),                          // Input
    .cpu_rspAddrOut(cpu_rspAddrOut),                        // Output
    .cpu_rspInsLineOut(cpu_rspInsLineOut),                  // Output
    .cpu_rspInsLineValidOut(cpu_rspInsLineValidOut),        // Output

    // Memory Interface
    .mem_rspTagIn(mem_rspTagIn),                            // Input
    .mem_rspInsLineIn(mem_rspInsLineIn),                    // Input
    .mem_rspInsLineValidIn(mem_rspInsLineValidIn),          // Input
    .mem_reqTagOut(c_mem_reqTagOut),                        // Output
    .mem_reqTagValidOut(c_mem_reqTagValidOut)               // Output
);

////////////////
// Prefetcher //
////////////////
ifu_prefetcher ifu_prefetcher (
    .Clock(Clock),                                          // Input
    .Rst(Rst),                                              // Input

    // Cache Interface
    .cache_rspTagValidIn(c2p_rspTagValid),                  // input
    .cache_rspTagStatusIn(c2p_rspTagStatus),                // input
    .cache_rspTagIn(c2p_rspTag),                            // input
    .cache_reqTagValidOut(p2c_reqTagValid),                 // Output 
    .cache_reqTagOut(p2c_reqTag),                           // Output 

    // IFU signals
    .ifu_prefReqSent(p_reqSent),                            // Input

    // CPU Interface
    .cpu_reqAddrIn(cpu_reqAddrIn),                          // Input
            
    // Memory Interface
    .mem_rspTagIn(mem_rspTagIn),                            // input
    .mem_rspInsLineValidIn(mem_rspInsLineValidIn),          // input
    .mem_reqTagOut(p_mem_reqTagOut),                        // Output  
    .mem_reqTagValidOut(p_mem_reqTagValidOut)               // Output
);


/////////////
// Assigns //
/////////////
assign insertionOnMiss = (c_mem_reqTagValidOut == VALID) && (mem_rspInsLineValidIn == VALID) && (c_mem_reqTagOut == mem_rspTagIn);
assign insertionOnPrefetch = (mem_rspInsLineValidIn == VALID) && (p_mem_reqTagValidOut == !VALID) && !insertionOnMiss;


///////////////////////////
// Always Comb Statement //
///////////////////////////
always_comb begin

    if (insertionOnMiss) begin
        mem_reqTagOut = c_mem_reqTagOut;
    end 

    if (insertionOnPrefetch) begin
        mem_reqTagOut = p_mem_reqTagOut;
        p_reqSent = VALID;
    end

    if (insertionOnMiss || insertionOnPrefetch) begin
        mem_reqTagValidOut = VALID;
    end

end

///////////////////////////
// Always_FF Statement //
///////////////////////////


endmodule

