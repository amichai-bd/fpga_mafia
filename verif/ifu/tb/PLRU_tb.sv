`timescale 1ns/1ps

module PLRU_tb;

    // Parameters
    parameter NUM_TAGS = 16;        // Number of tags (cache lines)
    parameter NUM_LINES = 16;       // Number of lines
    parameter TAG_WIDTH = 30;       // Width of each tag
    parameter LINE_WIDTH = 128;     // Width of each cache line
    parameter ADDR_WIDTH = 32;      // Address width
    parameter OFFSET_WIDTH = 4;     // Offset bits in address

    // Inputs
    logic Clock;
    logic Rst;
    logic [ADDR_WIDTH-1:0] cpu_reqAddrIn;
    logic [LINE_WIDTH-1:0] mem_rspInsLineIn;
    logic mem_rspInsLineValidIn;
    logic [TAG_WIDTH-1:0] mem_rspTagIn;

    // Outputs
    logic [ADDR_WIDTH-1:0] cpu_rspAddrOut;
    logic [LINE_WIDTH-1:0] cpu_rspInsLineOut;
    logic cpu_rspInsLineValidOut;
    logic [TAG_WIDTH-1:0] mem_reqTagOut;
    logic mem_reqTagValidOut;

    // Debug Outputs
    logic [LINE_WIDTH-1:0] debug_dataArray [NUM_LINES];
    logic [TAG_WIDTH-1:0] debug_tagArray [NUM_TAGS];
    logic [NUM_TAGS-1:0] debug_validArray;
    logic [NUM_LINES-2:0] debug_plruTree;

    // Instantiate the DUT (Device Under Test)
    ifu_cache #(
        .NUM_TAGS(NUM_TAGS),
        .NUM_LINES(NUM_LINES),
        .TAG_WIDTH(TAG_WIDTH),
        .LINE_WIDTH(LINE_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .OFFSET_WIDTH(OFFSET_WIDTH)
    ) dut (
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
        .debug_dataArray(debug_dataArray),
        .debug_tagArray(debug_tagArray),
        .debug_validArray(debug_validArray),
        .debug_plruTree(debug_plruTree)
    );

    // Clock generation
    always #5 Clock = ~Clock; // 10 ns clock period

    // Testbench Variables
    int test_counter = 0;

    // Test Procedure
    initial begin
        // Initialize signals
        Clock = 0;
        Rst = 0;
        cpu_reqAddrIn = 0;
        mem_rspInsLineIn = 0;
        mem_rspInsLineValidIn = 0;
        mem_rspTagIn = 0;

        // 1. Reset Behavior
        $display("Test %0d: Reset Behavior", ++test_counter);
        Rst = 1;
        #20; // Hold reset for 20 ns
        Rst = 0;
        #10;
        // Verify all entries are invalid and PLRU tree is reset
        for (int i = 0; i < NUM_TAGS; i++) begin
            assert(dut.debug_validArray[i] == 0) else $fatal("Reset failed for validArray[%0d].", i);
        end
        assert(dut.debug_plruTree == 0) else $fatal("PLRU tree reset failed.");

        // 2. Basic Cache Miss
        $display("Test %0d: Basic Cache Miss", ++test_counter);
        cpu_reqAddrIn = 32'h1000;  // Set request address
        mem_rspInsLineIn = 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF; // Line data
        mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
        mem_rspInsLineValidIn = 1;
        #10; // Wait for one clock cycle
        mem_rspInsLineValidIn = 0;
        assert(dut.cpu_rspInsLineValidOut == 0) else $fatal("Cache miss handling failed.");

        // Simulate response from memory
        mem_rspInsLineValidIn = 1;
        #10;
        mem_rspInsLineValidIn = 0;
        assert(dut.cpu_rspInsLineOut == 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF) else $fatal("Incorrect data inserted in cache.");

        // 3. Basic Cache Hit
        $display("Test %0d: Basic Cache Hit", ++test_counter);
        cpu_reqAddrIn = 32'h1000;  // Access the same address
        #10;
        assert(dut.cpu_rspInsLineValidOut == 1) else $fatal("Cache hit failed.");
        assert(dut.cpu_rspInsLineOut == 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF) else $fatal("Incorrect data retrieved on cache hit.");

        // 4. PLRU Replacement
        $display("Test %0d: PLRU Replacement", ++test_counter);
        for (int i = 0; i < NUM_LINES; i++) begin
            cpu_reqAddrIn = i * 4;  // Unique addresses
            mem_rspInsLineIn = 128'hA5A5A5A5 + i; // Unique data
            mem_rspInsLineValidIn = 1;
            mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
            #10;
            mem_rspInsLineValidIn = 0;
        end
        // Insert one more line to trigger replacement
        cpu_reqAddrIn = 32'hFFFF;
        mem_rspInsLineIn = 128'h123456789ABCDEF;
        mem_rspInsLineValidIn = 1;
        mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
        #10;
        mem_rspInsLineValidIn = 0;
        // Check replacement
        assert(dut.cpu_rspInsLineValidOut == 0) else $fatal("PLRU replacement failed.");
        
        $display("All tests passed!");
        $stop;
    end

endmodule
