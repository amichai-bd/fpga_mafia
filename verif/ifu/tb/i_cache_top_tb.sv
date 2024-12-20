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

initial begin: main_tb
    rst = 1;
    #20
    @(posedge clk)

    /**************************************
    / miss scenario at startup and then hit
    ***************************************/
    //access the cache in the first time - miss scenario
    rst = 0;
    pcQ100H = 32'h0000_beef;  // tag = 'bee'. offset = '3'
    i_mem2cache_rsp.valid = 0;
    #80
    @(posedge clk)

    //the imem returns the data at 32'h0000_beef address
    i_mem2cache_rsp.valid = 1;
    i_mem2cache_rsp.address = 32'h0000_beef;
    i_mem2cache_rsp.filled_instruction = 128'h01000000_02000000_03000000_04000000;
    #30
    @(posedge clk)
    
    // hit at 32'h0000_beef address
    #20
    @(posedge clk)
    
    // hit at 32'h0000_bee8 address
    pcQ100H = 32'h0000_bee8;  // tag = 'bee'. offset = '2'
    #20
    @(posedge clk)

    /**************************
    / second miss scenario 
    **************************/
    pcQ100H = 32'h0000_dea4;  // tag = 'dea'. offset = '1'
    i_mem2cache_rsp.valid = 0;
    #80
    @(posedge clk)

     //the imem returns the data at 32'h0000_beea address
    i_mem2cache_rsp.valid = 1;
    i_mem2cache_rsp.address = 32'h0000_dea4;
    i_mem2cache_rsp.filled_instruction = 128'h01000000_02000000_03000022_04000000;
    #80
    @(posedge clk)


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