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
`include "plru_macros.vh"

module plru
import ifu_pkg::*;
(

    input logic                         clk,
    input logic                         rst,
    input var t_cache_ctrl_plru         cache_ctrl_plru,      
    output logic [$clog2(WAYS_NUM)-1:0] evicted_cl   // the evicted cache line in case of miss
);

    // representation of 15 plru tree nodes
    t_plru_node [PLRU_NODES_NUM] plru_tree_nodes, next_plru_tree_nodes; 
    `MAFIA_EN_RST_DFF(plru_tree_nodes, next_plru_tree_nodes, clk, cache_ctrl_plru.update_tree,  rst)

    // when the cache is not full and we have miss we will it in the next available cache line
    // when cache is full the fill/eviction in case of miss will be determined by the PLRU and not the counter
    // this will happened when the counter exceeds 15
    logic [$clog2(WAYS_NUM):0] counter; 
    logic counter_en;
    // enable the counter when the cache is not full and we want to update the tree
    assign counter_en = ((counter < 5'h10) && (cache_ctrl_plru.update_tree));   
    `MAFIA_EN_RST_DFF(counter, counter+1, clk, counter_en, rst)

    /*                     PLRU tree representation
    ***********************************************************************
    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
        |   |   |   |   |   |   |   |   |   |    |    |    |    |    |    |
       *7*  |  *8*  |  *9*  |  *10* |  *11* |   *12*  |   *13*  |   *14*  |
        |   |   |   |   |   |   |   |   |   |    |    |    |    |    |    |
        |  *3*  |   |   |  *4*  |   |   |  *5*   |    |    |   *6*   |    |
        |   |   |   |   |   |   |   |   |   |    |    |    |    |    |    |
        |   |   |  *1*  |   |   |   |   |   |    |   *2*   |    |    |    |
        |   |   |   |   |   |   |   |   |   |    |    |    |    |    |    |
        |   |   |   |   |   |   |  *0*  |   |    |    |    |    |    |    |
    ***********************************************************************/
    logic  cache_miss_and_not_full;
    logic  cache_full;
    assign cache_full   = (counter == 5'h10) ? 1'b1 : 1'b0;  // when the counter reached 0x10 we fill CL's 0-f 
    assign cache_miss_and_not_full = ((!cache_full) && (cache_ctrl_plru.cache_miss));

    // "cache_miss_and_not_full" - in that case we fill the cache with the next available cache line pointed by the counter. 
    // must update the tree and send next cache line for eviction
    // "!cache miss" - in that case we only need to update the tree without any eviction 
  
    always_comb begin
        evicted_cl = 0;
        if(cache_miss_and_not_full) begin  // miss and cache is not full- the evicted CL is the counter
            `UPDATE_TREE(counter);
            evicted_cl = counter;
        end else if(!cache_ctrl_plru.cache_miss) begin  // hit
            `UPDATE_TREE(cache_ctrl_plru.hit_cl);
        end else begin // case of miss while the cache is full
            `SEARCH_EVICTED(evicted_cl);   
            `UPDATE_TREE(evicted_cl);
        end
    end


/*  TODO - remove those tasks after debug. macros added instead
task update_tree(input logic [$clog2(WAYS_NUM)-1:0] node);
    begin
        next_plru_tree_nodes = plru_tree_nodes;  // Initialize the next state
        case (node)
            4'h0: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[3].next_node_is_right = 0;
                next_plru_tree_nodes[3].next_node_is_left  = 1;
                next_plru_tree_nodes[7].next_node_is_right = 0;
                next_plru_tree_nodes[7].next_node_is_left  = 1;
            end
            4'h1: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[3].next_node_is_right = 0;
                next_plru_tree_nodes[3].next_node_is_left  = 1;
                next_plru_tree_nodes[7].next_node_is_right = 1;
                next_plru_tree_nodes[7].next_node_is_left  = 0;
            end
            4'h2: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[3].next_node_is_right = 1;
                next_plru_tree_nodes[3].next_node_is_left  = 0;
                next_plru_tree_nodes[8].next_node_is_right = 0;
                next_plru_tree_nodes[8].next_node_is_left  = 1;
            end
            4'h3: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[3].next_node_is_right = 1;
                next_plru_tree_nodes[3].next_node_is_left  = 0;
                next_plru_tree_nodes[8].next_node_is_right = 1;
                next_plru_tree_nodes[8].next_node_is_left  = 0;
            end
            4'h4: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[4].next_node_is_right = 0;
                next_plru_tree_nodes[4].next_node_is_left  = 1;
                next_plru_tree_nodes[9].next_node_is_right = 0;
                next_plru_tree_nodes[9].next_node_is_left  = 1;
            end
            4'h5: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[4].next_node_is_right = 0;
                next_plru_tree_nodes[4].next_node_is_left  = 1;
                next_plru_tree_nodes[9].next_node_is_right = 1;
                next_plru_tree_nodes[9].next_node_is_left  = 0;
            end
            4'h6: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[4].next_node_is_right = 1;
                next_plru_tree_nodes[4].next_node_is_left  = 0;
                next_plru_tree_nodes[10].next_node_is_right = 0;
                next_plru_tree_nodes[10].next_node_is_left  = 1;
            end
            4'h7: begin
                next_plru_tree_nodes[0].next_node_is_right = 0;
                next_plru_tree_nodes[0].next_node_is_left  = 1;
                next_plru_tree_nodes[1].next_node_is_right = 0;
                next_plru_tree_nodes[1].next_node_is_left  = 1;
                next_plru_tree_nodes[4].next_node_is_right = 1;
                next_plru_tree_nodes[4].next_node_is_left  = 0;
                next_plru_tree_nodes[10].next_node_is_right = 1;
                next_plru_tree_nodes[10].next_node_is_left  = 0;
            end
            4'h8: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 0;
                next_plru_tree_nodes[2].next_node_is_left  = 1;
                next_plru_tree_nodes[5].next_node_is_right = 0;
                next_plru_tree_nodes[5].next_node_is_left  = 1;
                next_plru_tree_nodes[11].next_node_is_right = 0;
                next_plru_tree_nodes[11].next_node_is_left  = 1;
            end
            4'h9: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 0;
                next_plru_tree_nodes[2].next_node_is_left  = 1;
                next_plru_tree_nodes[5].next_node_is_right = 0;
                next_plru_tree_nodes[5].next_node_is_left  = 1;
                next_plru_tree_nodes[11].next_node_is_right = 1;
                next_plru_tree_nodes[11].next_node_is_left  = 0;
            end
            4'hA: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 0;
                next_plru_tree_nodes[2].next_node_is_left  = 1;
                next_plru_tree_nodes[5].next_node_is_right = 1;
                next_plru_tree_nodes[5].next_node_is_left  = 0;
                next_plru_tree_nodes[12].next_node_is_right = 0;
                next_plru_tree_nodes[12].next_node_is_left  = 1;
            end
            4'hB: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 0;
                next_plru_tree_nodes[2].next_node_is_left  = 1;
                next_plru_tree_nodes[5].next_node_is_right = 1;
                next_plru_tree_nodes[5].next_node_is_left  = 0;
                next_plru_tree_nodes[12].next_node_is_right = 1;
                next_plru_tree_nodes[12].next_node_is_left  = 0;
            end
            4'hC: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 1;
                next_plru_tree_nodes[2].next_node_is_left  = 0;
                next_plru_tree_nodes[6].next_node_is_right = 0;
                next_plru_tree_nodes[6].next_node_is_left  = 1;
                next_plru_tree_nodes[13].next_node_is_right = 0;
                next_plru_tree_nodes[13].next_node_is_left  = 1;
            end
            4'hD: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 1;
                next_plru_tree_nodes[2].next_node_is_left  = 0;
                next_plru_tree_nodes[6].next_node_is_right = 0;
                next_plru_tree_nodes[6].next_node_is_left  = 1;
                next_plru_tree_nodes[13].next_node_is_right = 1;
                next_plru_tree_nodes[13].next_node_is_left  = 0;
            end
            4'hE: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 1;
                next_plru_tree_nodes[2].next_node_is_left  = 0;
                next_plru_tree_nodes[6].next_node_is_right = 1;
                next_plru_tree_nodes[6].next_node_is_left  = 0;
                next_plru_tree_nodes[14].next_node_is_right = 0;
                next_plru_tree_nodes[14].next_node_is_left  = 1;
            end
            4'hF: begin
                next_plru_tree_nodes[0].next_node_is_right = 1;
                next_plru_tree_nodes[0].next_node_is_left  = 0;
                next_plru_tree_nodes[2].next_node_is_right = 1;
                next_plru_tree_nodes[2].next_node_is_left  = 0;
                next_plru_tree_nodes[6].next_node_is_right = 1;
                next_plru_tree_nodes[6].next_node_is_left  = 0;
                next_plru_tree_nodes[14].next_node_is_right = 1;
                next_plru_tree_nodes[14].next_node_is_left  = 0;
            end
            default: begin
                next_plru_tree_nodes = plru_tree_nodes;  // No updates for invalid node
            end
        endcase
    end
endtask

task search_evicted(output logic [$clog2(WAYS_NUM)-1:0] evicted_cl);
    logic [$clog2(WAYS_NUM)-1:0] current_node;
    integer depth;
    depth = $clog2(WAYS_NUM);
    begin
        current_node = 0;

        // Traverse the tree
        for (integer i = 0; i < depth-1; i++) begin
            if (plru_tree_nodes[current_node].next_node_is_left) begin
                current_node = (current_node << 1) + 2; // Go to right child
            end else begin
                current_node = (current_node << 1) + 1; // Go to left child
            end
        end

        // Map the current_node to the opposite (plru algorithm) evicted cache line
        case (current_node)
            4'h7: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h1 : 4'h0;
            4'h8: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h3 : 4'h2;
            4'h9: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h5 : 4'h4;
            4'hA: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h7 : 4'h6;
            4'hB: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h9 : 4'h8;
            4'hC: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'hB : 4'hA;
            4'hD: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'hD : 4'hC;
            4'hE: evicted_cl = (plru_tree_nodes[current_node].next_node_is_left) ? 4'hF : 4'hE;
            default: evicted_cl = current_node; 
        endcase
    end
endtask
*/


endmodule
