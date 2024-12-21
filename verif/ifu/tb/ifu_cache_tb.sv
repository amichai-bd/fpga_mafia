`timescale 1ns / 1ps

module ifu_cache_tb;

import ifu_pkg::*;

// Testbench parameters
parameter NUM_TAGS = 16;           // Number of tags
parameter NUM_LINES = 16;          // Number of cache lines
parameter TAG_WIDTH = 27;          // Width of the tag (adjust based on your system design)
parameter LINE_WIDTH = 128;        // Cache line width (128 bits)
parameter ADDR_WIDTH = 32;         // Address width (32-bit addressing)
parameter OFFSET_WIDTH = 5;        // Offset width (log2(line size), here it's 5 for a 32-byte line)

// Testbench signals
logic Clock;
logic Rst;
logic [ADDR_WIDTH-1:0] cpu_reqAddrIn;
logic [ADDR_WIDTH-1:0] cpu_rspAddrOut;
logic [LINE_WIDTH-1:0] cpu_rspInsLineOut;
logic cpu_rspInsLineValidOut;
logic [TAG_WIDTH-1:0] mem_rspTagIn;
logic [LINE_WIDTH-1:0] mem_rspInsLineIn;
logic mem_rspInsLineValidIn;
logic [TAG_WIDTH-1:0] mem_reqTagOut;
logic mem_reqTagValidOut;
logic dataInsertion;

// Instantiate the ifu_cache module
ifu_cache #(
    .NUM_TAGS(NUM_TAGS),
    .NUM_LINES(NUM_LINES),
    .TAG_WIDTH(TAG_WIDTH),
    .LINE_WIDTH(LINE_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .OFFSET_WIDTH(OFFSET_WIDTH)
) uut (
    .Clock(Clock),
    .Rst(Rst),
    .cpu_reqAddrIn(cpu_reqAddrIn),
    .cpu_rspAddrOut(cpu_rspAddrOut),
    .cpu_rspInsLineOut(cpu_rspInsLineOut),
    .cpu_rspInsLineValidOut(cpu_rspInsLineValidOut),
    .mem_rspTagIn(mem_rspTagIn),
    .mem_rspInsLineIn(mem_rspInsLineIn),
    .mem_rspInsLineValidIn(mem_rspInsLineValidIn),
    .mem_reqTagOut(mem_reqTagOut),
    .mem_reqTagValidOut(mem_reqTagValidOut),
    .dataInsertion(dataInsertion)
);

// Clock generation
always begin
    #5 Clock = ~Clock; // 100 MHz clock period
end

// Test sequence
initial begin
    // Initialize signals
    Clock = 0;
    Rst = 0;
    cpu_reqAddrIn = 0;
    mem_rspTagIn = 0;
    mem_rspInsLineIn = 0;
    mem_rspInsLineValidIn = 0;

    // Apply reset
    Rst = 1;
    #10 Rst = 0;

    // Test Case 1: CPU makes a request to the cache (miss scenario)
    cpu_reqAddrIn = 32'h00000000; // Address 0x00000000
    #10;  // Wait for 1 clock cycle
    mem_rspTagIn = 27'h0000001;  // Example tag response from memory (adjust based on actual tag width)
    mem_rspInsLineIn = 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF; // Data from memory (example data)
    mem_rspInsLineValidIn = 1; // Memory line valid
    #10;  // Wait for 1 clock cycle to observe cache miss handling

    // Test Case 2: CPU makes another request to the same address (hit scenario)
    cpu_reqAddrIn = 32'h00000000; // Address 0x00000000 (same as before)
    #10;  // Wait for 1 clock cycle
    // No need to provide memory response as the data should be in cache now
    #10;  // Wait for response

    // Test Case 3: CPU makes a request to a different address (miss scenario)
    cpu_reqAddrIn = 32'h00000010; // Address 0x00000010 (different address)
    #10;  // Wait for 1 clock cycle
    mem_rspTagIn = 27'h0000002;  // Tag response from memory (example value)
    mem_rspInsLineIn = 128'hCAFEBABECAFEBABECAFEBABECAFEBABE; // Data from memory (example data)
    mem_rspInsLineValidIn = 1; // Memory line valid
    #10;  // Wait for 1 clock cycle to observe cache miss handling

    // Test Case 4: Simulate further requests to check cache replacement
    cpu_reqAddrIn = 32'h00000020; // Address 0x00000020 (new address)
    #10;
    mem_rspTagIn = 27'h0000003;
    mem_rspInsLineIn = 128'hFEEDC0DEFEEDC0DEFEEDC0DEFEEDC0DE;
    mem_rspInsLineValidIn = 1;
    #10;
    // cpu_reqAddrIn = 32'h00000000; // Back to first address (to check if data is still cached)
    #10;

    // End of test
    $stop;
end

// Monitor outputs
initial begin
    $monitor("At time %t, CPU requested addr: %h, MEM RSP Tag: %h, Response addr: %h, Line: %h, Valid: %b, Mem Req: %b, Insertion: %b ", 
             $time, cpu_reqAddrIn, mem_rspTagIn, cpu_rspAddrOut, cpu_rspInsLineOut, cpu_rspInsLineValidOut, mem_reqTagValidOut, dataInsertion);
end

endmodule
