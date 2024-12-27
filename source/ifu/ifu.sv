//-----------------------------------------------------------------------------
// Title            : instruction cache
// Project          : IFU - instruction getch unit
//-----------------------------------------------------------------------------
// File             : ifu_top.sv
// Original Author  : 
// Code Owner       : 
// Adviser          : 
// Created          : 12/2024
//-----------------------------------------------------------------------------
// Description      : ifu unit 
//-----------------------------------------------------------------------------
// TODO consider to separate cache_prefetcher from Imem

`include "macros.vh"

module ifu
import ifu_pkg::*;
(
    input logic                 clk,
    input logic                 rst,
    input logic [31:0]          pcQ100H,
    output var t_cache2core_rsp cache2core_rsp

);

var t_i_mem2cache_rsp    i_mem2cache_rsp;
var t_cache2i_mem_req    cache2i_mem_req;

i_cache_top i_cache_top
(
    .clk(clk),
    .rst(rst),
    .pcQ100H(pcQ100H),
    .i_mem2cache_rsp(i_mem2cache_rsp),
    .cache2i_mem_req(cache2i_mem_req),
    .cache2core_rsp(cache2core_rsp)
);

i_mem_wrap i_mem_wrap
(
    .clk(clk),
    .rst(rst),
    .cache2i_mem_req(cache2i_mem_req), 
    .i_mem2cache_rsp(i_mem2cache_rsp)

);

endmodule