// instruction memory TB

// ./build.py -dut ifu -hw -sim -top i_mem_tb

`include "macros.vh"

module i_mem_tb;
import ifu_pkg::*;

logic clock;
logic rst;
var t_cache2i_mem_req   cache2i_mem_req;
var t_i_mem2cache_rsp  i_mem2cache_rsp;


initial begin
    forever begin
        #5 clock = 0;
        #5 clock = 1;
    end
end

i_mem_wrap i_mem_wrap
(
    .clk(clock),
    .rst(rst),
    .cache2i_mem_req(cache2i_mem_req), 
    .i_mem2cache_rsp(i_mem2cache_rsp)

);

integer i;
initial begin : imem_memory_initialization
    for(i=0; i<5; i++) begin   // can be any other number
     i_mem_wrap.i_mem.mem[i] = i+1;
    end
end

initial begin
    rst = 1;
    #10
    rst = 0;
    @(posedge clock);

    cache2i_mem_req.fill_requested_address = 32'h0;
    cache2i_mem_req.fill_requested_address_valid = 1;
    #10
    @(posedge clock);

    cache2i_mem_req.fill_requested_address_valid = 0;
    #70
    @(posedge clock);

    cache2i_mem_req.fill_requested_address = 32'h1;
    cache2i_mem_req.fill_requested_address_valid = 1;
    #10
    @(posedge clock);

    cache2i_mem_req.fill_requested_address_valid = 0;
    #70
    @(posedge clock);

    cache2i_mem_req.fill_requested_address = 32'h2;
    cache2i_mem_req.fill_requested_address_valid = 1;
    #10
    @(posedge clock);

     cache2i_mem_req.fill_requested_address_valid = 0;
    #70
    @(posedge clock);
    
    #20

    $finish;
end

parameter V_TIMEOUT = 10000;
initial begin : timeout_check 
    #V_TIMEOUT
    $finish;
end


endmodule