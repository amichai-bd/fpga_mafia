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
    input logic                        clk,
    input logic                        rst,
    input logic [31:0]                 pcQ100H,
    input var t_i_mem2cache_rsp        i_mem2cache_rsp,
    input logic [$clog2(WAYS_NUM)-1:0] lru_tag,
    output var t_cache2i_mem_req       cache2i_mem_req,
    output var t_cache2core_rsp        cache2core_rsp,
    output var t_cache_ctrl_plru       plru_ctrl
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
assign fill_requested_address_q0       = pcQ100H;  // used when there is a miss to send to imem

// the following lines responsible of sending the valid instructions to the core
assign requested_cl_offset_q0 = pcQ100H[3:2];
always_comb begin
    instruction2core_q0       = 0;
    if(cache_hit_q0) begin  
        case(requested_cl_offset_q0) 
            2'b00: instruction2core_q0       = data_arr[hit_index_q0][31:0];
            2'b01: instruction2core_q0       = data_arr[hit_index_q0][63:32];
            2'b10: instruction2core_q0       = data_arr[hit_index_q0][95:64];
            2'b11: instruction2core_q0       = data_arr[hit_index_q0][127:96];
            default : ; // do nothing
        endcase
    end
end

//----------------------------
//  data, tag and valid arr
// ---------------------------
logic latch_enable_fill;
`MAFIA_RST_LATCH(data_arr[lru_tag], i_mem2cache_rsp.filled_instruction, latch_enable_fill, rst)
`MAFIA_RST_LATCH(tag_address_arr[lru_tag], i_mem2cache_rsp.address, latch_enable_fill, rst)
`MAFIA_RST_LATCH(tag_valid_arr[lru_tag], 1'b1, latch_enable_fill, rst)


//--------------------------
//     cache state machine
// -------------------------
t_cache_states state, next_state;
`MAFIA_RST_VAL_DFF(state, next_state, clk, rst, IDLE)
always_comb begin
    instruction2core_valid_q0       = 0; // stall core Q101H stage
    fill_requested_address_valid_q0 = 0; // address sended to i_mem is not valid 
    cache2core_rsp.stall_pc         = 0; // default do not stall
    latch_enable_fill               = 0; // do not fill latch data arr
    case(state)
        MISS_DETECTED: begin
            fill_requested_address_valid_q0 = 1; // sended to i_mem 
            cache2core_rsp.stall_pc         = 1; // stall pc
        end
        WAIT_FOR_IMEM: begin
            cache2core_rsp.stall_pc         = 1;  // stall pc

        end
        FILL_DATA_ARR: begin
            cache2core_rsp.stall_pc         = 1;  // stall pc
            latch_enable_fill               = 1;
        end
        HIT: begin
           instruction2core_valid_q0        = 1;
        end
    endcase
end

assign plru_ctrl.update_tree = (state == FILL_DATA_ARR) ? 1'b1 : 1'b0;
assign plru_ctrl.hit_cl      = hit_index_q0;
assign plru_ctrl.cache_miss  = !cache_hit_q0;

always_comb begin: state_transition
    next_state = (rst) ? IDLE : (cache_hit_q0) ? HIT : state;
    case(state)
        MISS_DETECTED: begin
            next_state = WAIT_FOR_IMEM;
        end
        WAIT_FOR_IMEM: begin
            if(!i_mem2cache_rsp.valid) 
                next_state = WAIT_FOR_IMEM;
            else 
                next_state = FILL_DATA_ARR;
        end
        FILL_DATA_ARR: begin
            next_state = IDLE;
        end
        default :next_state = HIT;

    endcase
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