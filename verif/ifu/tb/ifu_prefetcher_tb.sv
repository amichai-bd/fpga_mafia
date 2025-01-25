`timescale 1ns/1ps
module ifu_prefetcher_tb;

    import ifu_pkg::*;

    // Signals
    logic Clock;
    logic Rst;
    logic cache_rspTagValidIn;
    logic cache_rspTagStatusIn;
    logic [TAG_WIDTH-1:0] cache_rspTagIn;
    logic cache_reqTagValidOut;
    logic [TAG_WIDTH-1:0] cache_reqTagOut;
    logic ifu_prefReqSent;
    logic [ADDR_WIDTH-1:0] cpu_reqAddrIn;
    logic [TAG_WIDTH-1:0] mem_rspTagIn;
    logic mem_rspInsLineValidIn;
    logic [TAG_WIDTH-1:0] mem_reqTagOut;
    logic mem_reqTagValidOut;
    logic [TAG_WIDTH-1:0] cpu_reqTag;
    logic [1:0] current_state;

    assign cpu_reqTag =  cpu_reqAddrIn [ADDR_WIDTH - 1:OFFSET_WIDTH];

    // Clock generation
    always #5 Clock = ~Clock;

    // DUT instantiation
    ifu_prefetcher dut (
        .Clock(Clock),
        .Rst(Rst),
        .cache_rspTagValidIn(cache_rspTagValidIn),
        .cache_rspTagStatusIn(cache_rspTagStatusIn),
        .cache_rspTagIn(cache_rspTagIn),
        .cache_reqTagValidOut(cache_reqTagValidOut),
        .cache_reqTagOut(cache_reqTagOut),
        .ifu_prefReqSent(ifu_prefReqSent),
        .cpu_reqAddrIn(cpu_reqAddrIn),
        .mem_rspTagIn(mem_rspTagIn),
        .mem_rspInsLineValidIn(mem_rspInsLineValidIn),
        .mem_reqTagOut(mem_reqTagOut),
        .mem_reqTagValidOut(mem_reqTagValidOut),
        .current_stateOut(current_state)
    );

    // Testbench logic
    initial begin
        // Initialize signals
        Clock = 0;
        Rst = 1;
        cache_rspTagValidIn = 0;
        cache_rspTagIn = 0;
        ifu_prefReqSent = 0;
        cpu_reqAddrIn = 0;
        mem_rspTagIn = 0;
        mem_rspInsLineValidIn = 0;

        // Release reset
        $display("Release Reset");
        #10 Rst = 0;
        $display("current_state = %d", current_state);

        // Test 1: Cache miss
        #10 cpu_reqAddrIn = 32'h1000; // PC-tag = 100
        $display("current_state = %d", current_state);
        #10 cache_rspTagIn = 32'h101; // Cache does not have PC-tag + 1
        $display("current_state = %d", current_state);
        cache_rspTagValidIn = 1;
        cache_rspTagStatusIn = 0;
        #10
        $display("current_state = %d", current_state); 
        $display("Test 1 - Cache miss: cache_rspTagIn: %h, cache_reqTagOut: %h, mem_reqTagValidOut = %b, mem_reqTagOut = %h",cache_rspTagIn, cache_reqTagOut , mem_reqTagValidOut, mem_reqTagOut);

        // Test 2: Cache hit
        #20 cache_rspTagIn = 32'h101;
        $display("current_state = %d", current_state);
        cache_rspTagValidIn = 1;
        cache_rspTagStatusIn = 1;
        #10 
        $display("current_state = %d", current_state);
        $display("Test 2 - Cache hit: cache_rspTagIn: %h, cache_reqTagOut: %h, mem_reqTagValidOut = %b",cache_rspTagIn, cache_reqTagOut , mem_reqTagValidOut);

        // Test 3: Sleep mode
        #20 ifu_prefReqSent = 1;
        $display("current_state = %d", current_state);
        #10 
        $display("current_state = %d", current_state);
        $display("Test 3 - Sleep mode: cpu_reqTag: %h, mem_reqTagValidOut = %b, mem_reqTagOut = %h",cpu_reqTag , mem_reqTagValidOut, mem_reqTagOut);

        // Test 4: PC-tag change
        #10 cpu_reqAddrIn = 32'h2000; // PC-tag = 2
        $display("current_state = %d", current_state);
        #10 
        $display("current_state = %d", current_state);
        $display("Test 4 - PC-tag change: cpu_reqTag: %h, mem_reqTagValidOut = %b",cpu_reqTag , mem_reqTagValidOut);

        // Test 5: Reset
        #10 Rst = 1;
        $display("current_state = %d", current_state);
        #10 
        $display("current_state = %d", current_state);
        $display("Test 5 - Reset: cpu_reqTag: %h, mem_reqTagValidOut = %b",cpu_reqTag , mem_reqTagValidOut);

        $display("All tests completed!");
        $finish;
    end
endmodule
