`timescale 1ns/1ps

module PLRU_tb;

    // Parameters
    parameter NUM_TAGS = 16;        // Number of tags (cache lines)
    parameter NUM_LINES = 16;       // Number of lines
    parameter TAG_WIDTH = 30;       // Width of each tag
    parameter LINE_WIDTH = 128;     // Width of each cache line
    parameter OFFSET_WIDTH = 4;     // Offset bits in PC
    parameter ADDR_WIDTH = 32;      // Address width

    // Inputs
    logic Clock;
    logic Rst;
    logic [ADDR_WIDTH-1:0] cpu_reqAddrIn;
    logic [LINE_WIDTH-1:0] mem_rspInsLineIn;
    logic [TAG_WIDTH-1:0] mem_rspTagIn;
    logic mem_rspInsLineValidIn;

    // Outputs
    logic [ADDR_WIDTH-1:0] cpu_rspAddrOut;
    logic [LINE_WIDTH-1:0] cpu_rspInsLineOut;
    logic cpu_rspInsLineValidOut;
    logic [TAG_WIDTH-1:0] mem_reqTagOut;
    logic mem_reqTagValidOut;

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
        .mem_reqTagValidOut(mem_reqTagValidOut)
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
        mem_rspTagIn = 0;
        mem_rspInsLineIn = 128'h0;
        mem_rspInsLineValidIn = 0;

        // 1. Reset Behavior
        $display("Test %0d: Reset Behavior", ++test_counter);
        Rst = 1;
        #20; // Hold reset for 20 ns
        Rst = 0;
        #10;

        // Verify reset behavior
        assert(!cpu_rspInsLineValidOut) else $fatal("Reset failed: CPU response valid should be 0.");
        assert(!mem_reqTagValidOut) else $fatal("Reset failed: Memory request valid should be 0.");

        // 2. Basic Cache Miss
        $display("Test %0d: Basic Cache Miss", ++test_counter);
        cpu_reqAddrIn = 32'h1000;  // Set requested address
        mem_rspInsLineIn = 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF; // Simulate memory line data
        mem_rspTagIn = 30'h1000;  // Simulate tag from memory
        mem_rspInsLineValidIn = 1;
        #10; // Wait for one clock cycle
        mem_rspInsLineValidIn = 0;

        assert(mem_reqTagValidOut) else $fatal("Cache miss handling failed: Memory request not valid.");
        assert(cpu_rspInsLineValidOut) else $fatal("Cache miss handling failed: CPU response valid not set.");
        assert(cpu_rspInsLineOut == 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF) else $fatal("Cache miss handling failed: Incorrect data inserted.");

        // 3. Basic Cache Hit
        $display("Test %0d: Basic Cache Hit", ++test_counter);
        cpu_reqAddrIn = 32'h1000;  // Access the same address
        #10;

        assert(cpu_rspInsLineValidOut) else $fatal("Cache hit failed: CPU response valid not set.");
        assert(cpu_rspInsLineOut == 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF) else $fatal("Cache hit failed: Incorrect data retrieved.");

        // 4. PLRU Replacement
        $display("Test %0d: PLRU Replacement", ++test_counter);
        for (int i = 0; i < NUM_LINES; i++) begin
            cpu_reqAddrIn = i * 4;  // Unique addresses
            mem_rspInsLineIn = 128'hA5A5A5A5 + i; // Unique data
            mem_rspTagIn = i;  // Unique tags
            mem_rspInsLineValidIn = 1;
            #10;
            mem_rspInsLineValidIn = 0;
        end

        // Insert one more line to trigger replacement
        cpu_reqAddrIn = 32'hFFFF;
        mem_rspInsLineIn = 128'h123456789ABCDEF;
        mem_rspTagIn = 30'hFFFF;
        mem_rspInsLineValidIn = 1;
        #10;
        mem_rspInsLineValidIn = 0;

        assert(cpu_rspInsLineValidOut) else $fatal("PLRU replacement failed: CPU response valid not set.");
        assert(cpu_rspInsLineOut == 128'h123456789ABCDEF) else $fatal("PLRU replacement failed: Incorrect data after replacement.");

        $display("All tests passed!");
        $stop;
    end

endmodule
