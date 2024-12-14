//-----------------------------------------------------------------------------
// Title            : instruction cache
// Project          : IFU - instruction getch unit
//-----------------------------------------------------------------------------
// File             : i_cache.sv
// Original Author  : 
// Code Owner       : 
// Adviser          : 
// Created          : 11/2024
//-----------------------------------------------------------------------------
// Description      : 16 way fully associative instruction cache.
//-----------------------------------------------------------------------------

`include "macros.vh"

module i_cache
import ifu_pkg::*;
(   
    input logic                   clk,
    input logic                   rst,
    input logic [31:0]            pcQ100H,
    input var t_i_mem2cache_rsp   i_mem2cache_rsp,
    output var t_cache2i_mem_req  cache2i_mem_req,
    output var t_cache2core_rsp   cache2core_rsp
);

logic [CL_WIDTH-1:0]           data_arr [WAYS_NUM-1:0];        // holds the instruction
logic [CL_WIDTH-1:0]           tag_valid_arr;                  // hold if the instruction is valid
logic [TAG_ADDRESS_WIDTH-1 :0] tag_address_arr [WAYS_NUM-1:0]; //


logic                         cache_hit_q0;
logic [TAG_ADDRESS_WIDTH-1:0] requested_tag_address_q0;  // pcQ100[31:4]
logic [1:0]                   requested_cl_offset_q0;    // pcQ100[3:2]
logic [WAYS_NUM-1:0]          hit_array_q0;                 

logic [31:0] fill_requested_address_q0;         // address sended towards the i_mem in case of miss
logic        fill_requested_address_valid_q0;   // valid bit indicated that the requested address is valid

logic [31:0] instruction2core_q0;               // instruction to core    
logic        instruction2core_valid_q0;         // the instruction is valid

logic [$clog2(WAYS_NUM)-1:0] hit_index_q0;        // stores the index of the location of hit CL

//--------------------------
//     hit detection 
// -------------------------
// that block is responsible of finding it the requested block (cl) is in the cache
// that block compared all the valid tags located in the tag array with pc[31:4] 
// in case of match that hit occurred 
integer i;
assign requested_tag_address_q0 = pcQ100H[31:4];
always_comb begin : hit_detection
    hit_array_q0 = 0;
    hit_index_q0 = 0;
    for(i=0; i < WAYS_NUM; i++) begin
        // check if tag exists and valid is 1
        if((requested_tag_address_q0 == tag_address_arr[i]) && (tag_valid_arr[i] == 1)) begin
            hit_array_q0[i] = 1;
            hit_index_q0    = i;
        end
        else begin
            hit_array_q0[i] = 0;
        end
    end
end

assign cache_hit_q0 = |hit_array_q0;


assign fill_requested_address_q0       = pcQ100H;                    // used when there is a miss to send to imem
assign fill_requested_address_valid_q0 = (!cache_hit_q0) ? 1'b1 : 1'b0; // when miss the requested address for i_mem is valid


// the following lines responsible of sending the valid instructions to the core
assign requested_cl_offset_q0 = pcQ100H[3:2];
always_comb begin
    instruction2core_q0       = 0;
    instruction2core_valid_q0 = 0;
    if(cache_hit_q0) begin
        instruction2core_valid_q0 = 1'b1;
        case(requested_cl_offset_q0) 
            2'b00: instruction2core_q0       = data_arr[hit_index_q0][31:0];
            2'b01: instruction2core_q0       = data_arr[hit_index_q0][63:32];
            2'b10: instruction2core_q0       = data_arr[hit_index_q0][95:64];
            2'b11: instruction2core_q0       = data_arr[hit_index_q0][127:96];
            default : ; // do nothing
        endcase
    end
end

// we want that in case of hit the instruction will go to core at q101H cycle
// so thats the reason we add extra FF 
`MAFIA_RST_DFF(cache2core_rsp.requested_instruction,instruction2core_q0,clk,rst)
`MAFIA_RST_DFF(cache2core_rsp.requested_instruction_valid,instruction2core_valid_q0,clk,rst)


// signals to i_mem in case of miss
// add 1 cycle delay for reducing path (timing)
`MAFIA_RST_DFF(cache2i_mem_req.fill_requested_address_valid,fill_requested_address_valid_q0,clk,rst)
`MAFIA_RST_DFF(cache2i_mem_req.fill_requested_address,fill_requested_address_q0,clk,rst)
 

endmodule