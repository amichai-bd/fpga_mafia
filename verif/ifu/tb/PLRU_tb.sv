`timescale 1ns/1ps

module PLRU_tb;

    import ifu_pkg::*;
  
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
    logic hitStatusOut;
    logic dataInsertion;
    logic debug_freeLine;
    logic [LINE_WIDTH * NUM_LINES - 1:0] debug_dataArray;
    logic [(TAG_WIDTH + 1) * NUM_TAGS - 1:0] debug_tagArray;
    logic [NUM_LINES - 2:0] debug_plruTree;
    logic [P_BITS - 1:0] debug_plruIndex;

    // Instantiate the DUT (Device Under Test)
    ifu_cache 
     dut (
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
        .debug_freeline(debug_freeLine),
        .debug_dataArray(debug_dataArray),
        .debug_tagArray(debug_tagArray),
        .debug_plruTree(debug_plruTree),
        .debug_plruIndex(debug_plruIndex)
    );

    // Clock generation
    always #5 Clock = ~Clock; // 10 ns clock period

    // Testbench Variables
    int test_counter = 0;

    // Helper task to display the data array
    task display_data_array;
        $display("Data Array:");
        for (int line = 0; line < NUM_LINES; line++) begin
            $display("  Line %0d: %0h", line, dut.debug_dataArray[(line + 1) * LINE_WIDTH - 1 -: LINE_WIDTH]);
        end
    endtask

    // Helper task to display the tag array
    task display_tag_array;
        $display("Tag Array:");
        for (int tag = 0; tag < NUM_TAGS; tag++) begin
            $display("  Tag %0d: Valid: %0b, Tag: %0h", tag, dut.debug_tagArray[(tag + 1) * (TAG_WIDTH + 1) - 1], 
                     dut.debug_tagArray[(tag + 1) * (TAG_WIDTH + 1) - 2 -: TAG_WIDTH]);
        end
    endtask

    
initial begin
    // Initialize signals
    logic [7:0] temp_data; // Temporary variable for slicing
    int i; // Declare 'i' for loop

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
    $display("PLRU tree reset to: %0h", dut.debug_plruTree);
    display_data_array();
    display_tag_array();

    // 2. Basic Cache Miss
    $display("Test %0d: Basic Cache Miss", ++test_counter);
    cpu_reqAddrIn = 32'h1000;  // Set request address
    
    display_data_array();
    display_tag_array();

    
    #5
    // check if memory request is sent
    $display("Cache miss handled. Data insertion: %0b, hit: %0b, req data: %0h , %0b, rsp data: %0h, %0b", dut.dataInsertion, dut.hitStatusOut, dut.mem_reqTagOut, dut.mem_reqTagValidOut, mem_rspTagIn, mem_rspInsLineValidIn);
    // Simulate response from memory
    mem_rspInsLineIn = 128'hDEADBEEFDEADBEEFDEADBEEFDEADBEEF; // Line data
    mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
    mem_rspInsLineValidIn = 1;
    // check if data insertion mode is on
    #5
    $display("Cache miss handled. Data insertion: %0b, hit: %0b, req data: %0h , %0b, rsp data: %0h, %0b", dut.dataInsertion, dut.hitStatusOut, dut.mem_reqTagOut, dut.mem_reqTagValidOut, mem_rspTagIn, mem_rspInsLineValidIn);
    
    #10
    mem_rspInsLineValidIn = 0;
    $display("Inserted data: %0h", dut.cpu_rspInsLineOut);
    display_data_array();
    display_tag_array();

    // 3. Basic Cache Hit
    $display("Test %0d: Basic Cache Hit", ++test_counter);
    cpu_reqAddrIn = 32'h1000;  // Access the same address
    #10;
    $display("Cache hit. Valid line: %0b, Data: %0h", dut.cpu_rspInsLineValidOut, dut.cpu_rspInsLineOut);
    $display("PLRU tree after hit: %0h", dut.debug_plruTree);

    // 4. PLRU Replacement
    $display("Test %0d: PLRU Replacement", ++test_counter);
    for (i = 0; i < NUM_LINES; i++) begin
        cpu_reqAddrIn = i * 32;
        #5 // check if memory request is sent
        $display("Cache miss handled. Data insertion: %0b, hit: %0b, req data: %0h , %0b, rsp data: %0h, %0b", dut.dataInsertion, dut.hitStatusOut, dut.mem_reqTagOut, dut.mem_reqTagValidOut, mem_rspTagIn, mem_rspInsLineValidIn);
        #5 // simulate mem response
        temp_data = (i + 1) & 8'hFF; // Extract the lower 8 bits
        mem_rspInsLineIn = {16{temp_data}}; // Unique data
        mem_rspInsLineValidIn = 1;
        mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
        $display("Cache miss handled. Data insertion: %0b, hit: %0b, req data: %0h , %0b, rsp data: %0h, %0b", dut.dataInsertion, dut.hitStatusOut, dut.mem_reqTagOut, dut.mem_reqTagValidOut, mem_rspTagIn, mem_rspInsLineValidIn);
        #10;
        mem_rspInsLineValidIn = 0;
        $display("Inserted data for address %0h: %0h", cpu_reqAddrIn, mem_rspInsLineIn);
        display_data_array();
        display_tag_array();
    end

    // Insert one more line to trigger replacement
    cpu_reqAddrIn = 32'hFFFF;
    temp_data = 8'hFF; // Unique data for this case
    mem_rspInsLineIn = {16{temp_data}};
    mem_rspInsLineValidIn = 1;
    mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
    #10;
    mem_rspInsLineValidIn = 0;

    $display("PLRU replacement executed. Evicted index: %0h", dut.debug_plruIndex);
    $display("PLRU tree after replacement: %0h", dut.debug_plruTree);
    display_data_array();
    display_tag_array();

    // 5. Re-accessing Evicted Line
    $display("Test %0d: Re-accessing Evicted Line", ++test_counter);
    cpu_reqAddrIn = 32'hFFFF; // Accessing evicted line
    #10;
    $display("Cache hit status: %0b, Retrieved data: %0h", dut.cpu_rspInsLineValidOut, dut.cpu_rspInsLineOut);
    display_data_array();
    display_tag_array();


    // Insert a second line to trigger replacement again
    $display("Test %0d: PLRU Replacement (2nd trigger)", ++test_counter);
    cpu_reqAddrIn = 32'hFFFE;
    temp_data = 8'hFE; // Unique data for this case
    mem_rspInsLineIn = {16{temp_data}};
    mem_rspInsLineValidIn = 1;
    mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
    #10;
    mem_rspInsLineValidIn = 0;

    $display("PLRU replacement executed. Evicted index: %0h", dut.debug_plruIndex);
    $display("PLRU tree after replacement: %0h", dut.debug_plruTree);
    display_data_array();
    display_tag_array();

    // Insert a third line to trigger replacement again
    $display("Test %0d: PLRU Replacement (3rd trigger)", ++test_counter);
    cpu_reqAddrIn = 32'hFFFD;
    temp_data = 8'hFD; // Unique data for this case
    mem_rspInsLineIn = {16{temp_data}};
    mem_rspInsLineValidIn = 1;
    mem_rspTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH];
    #10;
    mem_rspInsLineValidIn = 0;

    $display("PLRU replacement executed. Evicted index: %0h", dut.debug_plruIndex);
    $display("PLRU tree after replacement: %0h", dut.debug_plruTree);
    $display("Final Data Array:");
    display_data_array();
    $display("Final Tag Array:");
    display_tag_array();


    $display("All tests completed!");
    $stop;
end


endmodule
