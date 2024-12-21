`timescale 1ns / 1ps

module tb_ifu_cache;

import ifu_pkg::*;

    // Testbench parameters
    localparam NUM_TAGS = 4;           // Example number of tags (set this as per your requirement)
    localparam NUM_LINES = 4;          // Example number of cache lines
    localparam TAG_WIDTH = 6;          // Example tag width
    localparam LINE_WIDTH = 32;        // Example line width (could be 32 bits per cache line)
    localparam ADDR_WIDTH = 32;        // Example address width (could be 32-bit address)
    localparam OFFSET_WIDTH = 5;       // Example offset width for 32-bit word size (log2(32) = 5)

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
        .mem_reqTagValidOut(mem_reqTagValidOut)
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
        mem_rspTagIn = 6'h1;  // Tag response from memory (example value)
        mem_rspInsLineIn = 32'hDEADBEEF; // Data from memory (example data)
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
        mem_rspTagIn = 6'h2;  // Tag response from memory (example value)
        mem_rspInsLineIn = 32'hCAFEBABE; // Data from memory (example data)
        mem_rspInsLineValidIn = 1; // Memory line valid
        #10;  // Wait for 1 clock cycle to observe cache miss handling

        // Test Case 4: Simulate further requests to check cache replacement
        cpu_reqAddrIn = 32'h00000020; // Address 0x00000020 (new address)
        #10;
        mem_rspTagIn = 6'h3;
        mem_rspInsLineIn = 32'hFEEDC0DE;
        mem_rspInsLineValidIn = 1;
        #10;
        cpu_reqAddrIn = 32'h00000000; // Back to first address (to check if data is still cached)
        #10;

        // End of test
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %t, CPU requested addr: %h, Response addr: %h, Line: %h, Valid: %b", 
                 $time, cpu_reqAddrIn, cpu_rspAddrOut, cpu_rspInsLineOut, cpu_rspInsLineValidOut);
    end

endmodule
