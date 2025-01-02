`include "macros.vh"

module ifu
import ifu_pkg::*;
(
    // Chip Signals
    input logic Clock,
    input logic Rst,

    // CPU Interface
    input logic [ADDR_WIDTH-1:0] cpu_reqAddrIn, // Address requested by the CPU
    // i think maybe we don't have to put this as an output because the CPU don't care about it. but i put it just in case 
    output logic [ADDR_WIDTH-1:0] cpu_rspAddrOut, // Address of the line in the response to CPU 
    output logic [LINE_WIDTH-1:0] cpu_rspInsLineOut, // Instruction line in the response to CPU
    output logic cpu_rspInsLineValidOut, // Indicates if the response is valid

    // Memory Interface
    input logic mem_ready_in,                      // Indicates if memory is ready for requests
    input logic [TAG_WIDTH-1:0] mem_rspTagIn,      // Tag of the line provided by memory
    input logic [LINE_WIDTH-1:0] mem_rspInsLineIn, // Line data provided by memory
    input logic mem_rspInsLineValidIn,            // Valid signal for memory response
    output logic [ADDR_WIDTH-1:0] mem_reqAddrOut, // Address requested by the IFU
    output logic mem_reqValidOut                  // Indicates if a memory request is valid
);



// Cache Module
    ifu_cache ifu_cache (
        .Clock(Clock),                                        // Input
        .Rst(Rst),                                            // Input
        // CPU Interface
        .cpu_reqAddrIn(cpu_reqAddrIn),                        // Input
        .cpu_rspAddrOut(cpu_rspAddrOut),                      // Output
        .cpu_rspInsLineOut(cpu_rspInsLineOut),                // Output
        .cpu_rspInsLineValidOut(cpu_rspInsLineValidOut),      // Output
        // Memory Interface
        .mem_rspTagIn(mem_rspTagIn),                          // Input
        .mem_rspInsLineIn(mem_rspInsLineIn),                  // Input
        .mem_rspInsLineValidIn(mem_rspInsLineValidIn),        // Input
        .mem_reqTagOut(mem_reqAddrOut),                       // Output
        .mem_reqTagValidOut(mem_reqValidOut),                 // Output
        // Prefetcher Interface
        .cache_miss_addr_out(cache_miss_addr),                // Output
        .cache_miss_valid_out(cache_miss_valid)               // Output
    );



    // Prefetcher Module
    ifu_prefetcher ifu_prefetcher (
        .Clock(Clock),                                        // Input
        .Rst(Rst),                                            // Input
        // CPU Interface
        .cpu_reqAddrIn(cpu_reqAddrIn),                        // Input
        // Cache Interface
        .cache_miss_addr_in(cache_miss_addr),                 // Input
        .cache_miss_valid_in(cache_miss_valid),               // Input
        .prefetch_addr_out(prefetch_addr),                    // Output
        .prefetch_addr_valid_out(prefetch_valid),             // Output
        // Memory Interface
        .mem_prefetch_ready_in(mem_ready_in),                 // Input
        .mem_prefetch_addr_out(mem_prefetch_addr),            // Output
        .mem_prefetch_valid_out(mem_prefetch_valid)           // Output
    );








endmodule

