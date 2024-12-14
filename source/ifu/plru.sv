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
    input var t_cache_ctrl2_plru        cache_ctrl2_plru,    
    input logic                         cache_miss,  
    input logic  [$clog2(WAYS_NUM)-1:0] hit_cl,      // in case of last hit we have to update as most recently used (MRU) 
    output logic [$clog2(WAYS_NUM)-1:0] evicted_cl   // the evicted cache line in case of miss
);

    // representation of 15 plru tree nodes
    t_plru_node [PLRU_NODES_NUM] plru_tree_nodes, next_plru_tree_nodes; 
    `MAFIA_EN_RST_DFF(plru_tree_nodes, next_plru_tree_nodes, clk, cache_ctrl2_plru.update_counter,  rst)

    // when the cache is not full and we have miss we will it in the next available cache line
    // when cache is full the fill/eviction in case of miss will be determined by the PLRU and not the counter
    logic [$clog2(WAYS_NUM)-1:0] counter, next_counter; 
    assign next_counter = (cache_miss == 1) ? counter + 1 : counter;
    `MAFIA_EN_RST_DFF(counter, next_counter, clk, cache_ctrl2_plru.update_tree, rst)

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
    assign cache_full   = (counter == 4'hf) ? 1'b1 : 1'b0;
    assign cache_miss_and_not_full = (!cache_full) && cache_miss;

    // "cache_miss_and_not_full" - in that case we fill the cache with the next available cache line pointed by the counter. 
    // must update the tree and send next cache line for eviction
    // "!cache miss" - in that case we only need to update the tree without any eviction 
    always_comb begin
        evicted_cl = 0;
        if(cache_miss_and_not_full) begin
            update_tree(counter);
            evicted_cl = counter;
        end else if(!cache_miss) begin
            update_tree(hit_cl);
        end else begin // case of miss
            search_evicted(evicted_cl);
            update_tree(evicted_cl);
        end
    end



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
                next_plru_tree_nodes[7].next_node_is_right = 1;
                next_plru_tree_nodes[7].next_node_is_left  = 0;
            end
            4'h2: begin
                next_plru_tree_nodes[3].next_node_is_right = 1;
                next_plru_tree_nodes[3].next_node_is_left  = 0;
                next_plru_tree_nodes[8].next_node_is_right = 0;
                next_plru_tree_nodes[8].next_node_is_left  = 1;
            end
            4'h3: begin
                next_plru_tree_nodes[8].next_node_is_right = 1;
                next_plru_tree_nodes[8].next_node_is_left  = 0;
            end
            4'h4: begin
                next_plru_tree_nodes[1].next_node_is_right = 1;
                next_plru_tree_nodes[1].next_node_is_left  = 0;
                next_plru_tree_nodes[4].next_node_is_right = 0;
                next_plru_tree_nodes[4].next_node_is_left  = 1;
                next_plru_tree_nodes[9].next_node_is_right = 0;
                next_plru_tree_nodes[9].next_node_is_left  = 1;
            end
            4'h5: begin
                next_plru_tree_nodes[9].next_node_is_right = 1;
                next_plru_tree_nodes[9].next_node_is_left  = 0;
            end
            4'h6: begin
                next_plru_tree_nodes[4].next_node_is_right = 1;
                next_plru_tree_nodes[4].next_node_is_left  = 0;
                next_plru_tree_nodes[10].next_node_is_right = 0;
                next_plru_tree_nodes[10].next_node_is_left  = 1;
            end
            4'h7: begin
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
                next_plru_tree_nodes[11].next_node_is_right = 1;
                next_plru_tree_nodes[11].next_node_is_left  = 0;
            end
            4'hA: begin
                next_plru_tree_nodes[5].next_node_is_right = 1;
                next_plru_tree_nodes[5].next_node_is_left  = 0;
                next_plru_tree_nodes[12].next_node_is_right = 0;
                next_plru_tree_nodes[12].next_node_is_left  = 1;
            end
            4'hB: begin
                next_plru_tree_nodes[12].next_node_is_right = 1;
                next_plru_tree_nodes[12].next_node_is_left  = 0;
            end
            4'hC: begin
                next_plru_tree_nodes[2].next_node_is_right = 1;
                next_plru_tree_nodes[2].next_node_is_left  = 0;
                next_plru_tree_nodes[6].next_node_is_right = 0;
                next_plru_tree_nodes[6].next_node_is_left  = 1;
                next_plru_tree_nodes[13].next_node_is_right = 0;
                next_plru_tree_nodes[13].next_node_is_left  = 1;
            end
            4'hD: begin
                next_plru_tree_nodes[13].next_node_is_right = 1;
                next_plru_tree_nodes[13].next_node_is_left  = 0;
            end
            4'hE: begin
                next_plru_tree_nodes[6].next_node_is_right = 1;
                next_plru_tree_nodes[6].next_node_is_left  = 0;
                next_plru_tree_nodes[14].next_node_is_right = 0;
                next_plru_tree_nodes[14].next_node_is_left  = 1;
            end
            4'hF: begin
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
    logic [PLRU_NODES_NUM-1:0] current_node; // Current node in the tree traversal
    begin
        current_node = 0; 

        while (current_node < WAYS_NUM - 1) begin
            if (plru_tree_nodes[current_node].next_node_is_left) begin
                // If the current node prefers left, go right (opposite)
                current_node = (current_node << 1) + 2; // Move to the right child
            end else begin
                // If the current node prefers right, go left (opposite)
                current_node = (current_node << 1) + 1; // Move to the left child
            end
        end

        evicted_cl = current_node - (WAYS_NUM - 1);
    end
endtask



endmodule
