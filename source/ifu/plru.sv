//-----------------------------------------------------------------------------
// Title            : Pseudo leats recently used algorithm
// Project          : IFU - instruction fetch unit
//-----------------------------------------------------------------------------
// File             : plru.sv
// Original Author  : 
// Code Owner       : 
// Adviser          : 
// Created          : 11/2024
//-----------------------------------------------------------------------------
// Description      : pseudo least recently used algorithm 
//-----------------------------------------------------------------------------

`include "macros.vh"

module plru
import ifu_pkg::*;
(

    input logic                         clk,
    input logic                         rst,
    input logic                         cache_miss,  
    input logic                         cache_full,  // if set cache is full and eviction is required in case of miss
    output logic [$clog2(WAYS_NUM)-1:0] evicted_cl   // the evicted cache line in case of miss
);

    t_plru_tree_nodes plru_tree_nodes; // representation of 15 plru tree nodes



endmodule