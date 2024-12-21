// i_cache_top_tb
// ./build.py -dut ifu -hw -sim -top i_cache_top_tb
`include "macros.vh"

module i_cache_top_tb;
import ifu_pkg::*;

    logic                     clk;
    logic                     rst;
    logic [31:0]              pcQ100H;
    var t_i_mem2cache_rsp     i_mem2cache_rsp;
    var t_cache2i_mem_req     cache2i_mem_req;
    var t_cache2core_rsp      cache2core_rsp;

 i_cache_top i_cache_top
(
    .clk(clk),
    .rst(rst),
    .pcQ100H(pcQ100H),
    .i_mem2cache_rsp(i_mem2cache_rsp),
    .cache2i_mem_req(cache2i_mem_req),
    .cache2core_rsp(cache2core_rsp)
);

// clock generator
initial begin
    forever begin
        #5 clk = 0;
        #5 clk = 1;
    end
end

integer i;
initial begin: main_tb
    rst = 1;
    #20;
    @(posedge clk);

    /**************************************
    / First miss scenario at startup
    ***************************************/
    rst = 0;
    pcQ100H = 32'h0000_beef;  // tag = 'bee'. offset = '3'
    i_mem2cache_rsp.valid = 0;
    #80;
    @(posedge clk);

    // The imem returns the data at 32'h0000_beef address
    i_mem2cache_rsp.valid = 1;
    i_mem2cache_rsp.address = 32'h0000_beef;
    i_mem2cache_rsp.filled_instruction = 128'h01000000_02000000_03000000_04000000;
    #30;
    @(posedge clk);

    // Hit at 32'h0000_beef address
    #20;
    @(posedge clk);

    // Hit at 32'h0000_bee8 address
    pcQ100H = 32'h0000_bee8;  // tag = 'bee'. offset = '2'
    #20;
    @(posedge clk);

    /**************************************
    / Fill all 16 ways of the cache
    ***************************************/
    for (integer i = 1; i < WAYS_NUM; i++) begin
        // Generate a unique address for each way
        pcQ100H = 32'h0000_0000 + (i * 32);  // Adjust as per cache indexing logic
        i_mem2cache_rsp.valid = 0;
        #80;
        @(posedge clk);

        // Simulate a miss and load data into the cache
        i_mem2cache_rsp.valid = 1;
        i_mem2cache_rsp.address = pcQ100H;
        i_mem2cache_rsp.filled_instruction = 
            128'h01000000_02000000_03000000_04000000 + (i * 100);  // Unique data for each way
        #80;
        @(posedge clk);

        // Simulate a hit for the same address
        pcQ100H = pcQ100H;  // Same address for a hit
        #40;
        @(posedge clk);
    end

    $display("cache is full at %t", $time);

    /***********************************************************
    / Test PLRU updates by accessing two different cache lines
    / The cache lines are already in the cache - hit 
    ***********************************************************/
    // Access cache line 1
    pcQ100H = 32'h0000_0020;  
    #40
    @(posedge clk);  // Simulate a hit for this tag

    // Access cache line 2
    pcQ100H = 32'h0000_0040;  

    @(posedge clk);  // Simulate a hit for this tag
    #40

    /***********************************************************
    / Miss scenario after cache is full
    / This should trigger a replacement and update LRU
    ***********************************************************/
    pcQ100H = 32'h0001_0000;  // A new address not in the cache
    i_mem2cache_rsp.valid = 0;
    #80;
    @(posedge clk);

    // The imem returns the data at 32'h0001_0000 address
    i_mem2cache_rsp.valid = 1;
    i_mem2cache_rsp.address = pcQ100H;
    i_mem2cache_rsp.filled_instruction = 128'hAA000000_BB000000_CC000000_DD000000;  
    #80;
    @(posedge clk);

     /**********************************
    / Two hits and another miss scenario
    ************************************/
    // Hit on cache line 3
    pcQ100H = 32'h0000_0060;  
    #40;
    @(posedge clk);

    // Hit on cache line 4
    pcQ100H = 32'h0000_0080;  
    #40;
    @(posedge clk);

    // Another miss scenario
    pcQ100H = 32'h0001_0020;  // Another new address not in the cache
    i_mem2cache_rsp.valid = 0;
    #80;
    @(posedge clk);

    // The imem returns the data at 32'h0001_0020 address
    i_mem2cache_rsp.valid = 1;
    i_mem2cache_rsp.address = pcQ100H;
    i_mem2cache_rsp.filled_instruction = 128'hFF000000_EE000000_DD000000_CC000000;  
    #80;
    @(posedge clk);

    $finish;
end


// force finish by timeout
parameter V_TIMEOUT = 10000;
initial begin:time_out_detection
    #V_TIMEOUT
    $display("timeout reached");
    $finish;
end
endmodule