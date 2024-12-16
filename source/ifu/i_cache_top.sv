`include "macros.vh"


module i_cache_top
import ifu_pkg::*;
(
    input logic                        clk,
    input logic                        rst,
    input logic [31:0]                 pcQ100H,
    input var t_i_mem2cache_rsp        i_mem2cache_rsp,
    output var t_cache2i_mem_req       cache2i_mem_req,
    output var t_cache2core_rsp        cache2core_rsp
);

logic [$clog2(WAYS_NUM)-1:0] lru_tag;
var t_cache_ctrl_plru        plru_ctrl;

i_cache i_cache
(   
    .clk(clk),
    .rst(rst),
    .pcQ100H(pcQ100H),
    .i_mem2cache_rsp(i_mem2cache_rsp),
    .lru_tag(lru_tag),
    .cache2i_mem_req(i_mem2cache_rsp),
    .cache2core_rsp(cache2core_rsp),
    .plru_ctrl(plru_ctrl)
);

plru plru
(

    .clk(clk),
    .rst(rst),
    .cache_ctrl_plru(plru_ctrl),    
    .evicted_cl(lru_tag)   // the evicted cache line in case of miss
);
endmodule