`timescale 1ns/1ps
`include "macros.vh"

module ifu_cache_tb;

    // Import parameters from ifu_pkg
    import ifu_pkg::*;

    // Signals
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
    logic hitStatusOut;
    logic [NUM_LINES-2:0] plruTreeOut;

    // Instantiate the module under test (MUT)
    ifu_cache dut (
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
        .dataInsertion(dataInsertion),
        .hitStatusOut(hitStatusOut),
        .plruTreeOut(plruTreeOut)
    );

    // Clock generation
    initial Clock = 0;
    always #5 Clock = ~Clock; // 100 MHz clock

    // Test procedure
    initial begin
        // Initialize signals
        $display("start");
        Rst = 1;
        cpu_reqAddrIn = 0;
        mem_rspTagIn = 0;
        mem_rspInsLineIn = 0;
        mem_rspInsLineValidIn = 0;

        // Apply reset
        #10 Rst = 0;

        // Test Case 1: Cache miss
        cpu_reqAddrIn = 32'h12345678; // Example address
        #10; // Wait for response
        $display("Test Case 1 - Cache Miss");
        $display("cpu_rspInsLineValidOut: %b", cpu_rspInsLineValidOut);
        $display("mem_reqTagOut: %h", mem_reqTagOut);
        $display("mem_reqTagValidOut: %b", mem_reqTagValidOut);

        // Test Case 2: Cache hit after insertion
        mem_rspInsLineIn = 64'hDEADBEEFDEADBEEF;
        mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
        mem_rspInsLineValidIn = 1;
        #10; // Wait for insertion to complete
        $display("Test Case 2 - Cache Hit");
        $display("cpu_rspInsLineValidOut: %b", cpu_rspInsLineValidOut);
        $display("cpu_rspInsLineOut: %h", cpu_rspInsLineOut);

        // Test Case 3: Validate PLRU tree update
        $display("PLRU Tree State: %b", plruTreeOut);

        // Finish simulation
        #20;
        $finish;
    end
endmodule
