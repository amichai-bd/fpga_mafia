//-----------------------------------------------------------------------------
// Title            : instruction memory wrapper
// Project          : IFU - instruction fetch unit
//-----------------------------------------------------------------------------
// File             : i_mem.sv
// Original Author  : 
// Code Owner       : 
// Adviser          : 
// Created          : 11/2024
//-----------------------------------------------------------------------------
// Description      : acts as instruction memory wrapper. Responsible to manage
//                    Responsible to handle aligned communication between mem
//                    and cache in terms of data validity
//-----------------------------------------------------------------------------

`include "macros.vh"
module i_mem_wrap
import ifu_pkg::*;
(
    input logic                   clk,
    input logic                   rst,
    input var t_cache2i_mem_req   cache2i_mem_req, 
    output var t_i_mem2cache_rsp  i_mem2cache_rsp

);

// signals used mostly for easier debug because they have pipe stage in their names
// the stage relatively to cpu PcQ100H happends 1 cycle after we detect miss (q1 stage)
logic [TAG_ADDRESS_WIDTH-1:0] tag_address_request_q1;
logic                         fill_requested_address_valid_q1;                      
assign tag_address_request_q1          = cache2i_mem_req.fill_requested_address[31:4];
assign fill_requested_address_valid_q1 = cache2i_mem_req.fill_requested_address_valid;

i_mem #(.DATA_WIDTH(CL_WIDTH), .ADRS_WIDTH(32))
i_mem
(
    .clock(clk),
    .address({4'b0, tag_address_request_q1}), 
    .wren(0),   // used as ROM. Data is forced in TB
    .data('0),  // used as ROM so its not important. data is forced in TB 
    .q(i_mem2cache_rsp.filled_instruction)        
);

/***************************
* Valid mechanism detection
****************************/
// the latency is based upon DE10-LITE sdram that can return burst of 16bit at each cycle
// meaning that the instruction memory has latency of 8
// just change the IMEM_LATENCY parameter
parameter IMEM_LATENCY = 8;

logic [IMEM_LATENCY-1:0] valid_shift_register, next_valid_shift_register;
assign next_valid_shift_register = {fill_requested_address_valid_q1, valid_shift_register[IMEM_LATENCY-1:1]};
`MAFIA_RST_DFF(valid_shift_register, next_valid_shift_register, clk, rst)    

// after 8 cycles valid_shift_register[0] will have the valid bit
// that bit will indicate to cache that the requested data is valid for fill
// communication protocol between cache and i_mem explanation:
// The cache sends valid bit for 1 cycle and after 8 executives cycles the instruction from i_mem is valid
// the cache must keep the address stable for 8 executive cycles after valid bit
assign i_mem2cache_rsp.valid   = (valid_shift_register[0] == 1'b1) ? 1'b1 : 1'b0;
assign i_mem2cache_rsp.address =  cache2i_mem_req.fill_requested_address; // cache sends sticky address that changes only at new miss request. TODO - possible change that rule


endmodule