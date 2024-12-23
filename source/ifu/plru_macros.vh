// PLRU update and search tree macros

`ifndef PLRU_MACROS_VH
`define PLRU_MACROS_VH

`define UPDATE_TREE(NODE) \
        next_plru_tree_nodes = plru_tree_nodes; \
        case (NODE) \
            4'h0: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[3].next_node_is_right = 0; \
                next_plru_tree_nodes[3].next_node_is_left  = 1; \
                next_plru_tree_nodes[7].next_node_is_right = 0; \
                next_plru_tree_nodes[7].next_node_is_left  = 1; \
            end \
            4'h1: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[3].next_node_is_right = 0; \
                next_plru_tree_nodes[3].next_node_is_left  = 1; \
                next_plru_tree_nodes[7].next_node_is_right = 1; \
                next_plru_tree_nodes[7].next_node_is_left  = 0; \
            end \
            4'h2: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[3].next_node_is_right = 1; \
                next_plru_tree_nodes[3].next_node_is_left  = 0; \
                next_plru_tree_nodes[8].next_node_is_right = 0; \
                next_plru_tree_nodes[8].next_node_is_left  = 1; \
            end \
            4'h3: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[3].next_node_is_right = 1; \
                next_plru_tree_nodes[3].next_node_is_left  = 0; \
                next_plru_tree_nodes[8].next_node_is_right = 1; \
                next_plru_tree_nodes[8].next_node_is_left  = 0; \
            end \
            4'h4: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[4].next_node_is_right = 0; \
                next_plru_tree_nodes[4].next_node_is_left  = 1; \
                next_plru_tree_nodes[9].next_node_is_right = 0; \
                next_plru_tree_nodes[9].next_node_is_left  = 1; \
            end \
            4'h5: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[4].next_node_is_right = 0; \
                next_plru_tree_nodes[4].next_node_is_left  = 1; \
                next_plru_tree_nodes[9].next_node_is_right = 1; \
                next_plru_tree_nodes[9].next_node_is_left  = 0; \
            end \
            4'h6: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[4].next_node_is_right = 1; \
                next_plru_tree_nodes[4].next_node_is_left  = 0; \
                next_plru_tree_nodes[10].next_node_is_right = 0; \
                next_plru_tree_nodes[10].next_node_is_left  = 1; \
            end \
            4'h7: begin \
                next_plru_tree_nodes[0].next_node_is_right = 0; \
                next_plru_tree_nodes[0].next_node_is_left  = 1; \
                next_plru_tree_nodes[1].next_node_is_right = 0; \
                next_plru_tree_nodes[1].next_node_is_left  = 1; \
                next_plru_tree_nodes[4].next_node_is_right = 1; \
                next_plru_tree_nodes[4].next_node_is_left  = 0; \
                next_plru_tree_nodes[10].next_node_is_right = 1; \
                next_plru_tree_nodes[10].next_node_is_left  = 0; \
            end \
            4'h8: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 0; \
                next_plru_tree_nodes[2].next_node_is_left  = 1; \
                next_plru_tree_nodes[5].next_node_is_right = 0; \
                next_plru_tree_nodes[5].next_node_is_left  = 1; \
                next_plru_tree_nodes[11].next_node_is_right = 0; \
                next_plru_tree_nodes[11].next_node_is_left  = 1; \
            end \
            4'h9: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 0; \
                next_plru_tree_nodes[2].next_node_is_left  = 1; \
                next_plru_tree_nodes[5].next_node_is_right = 0; \
                next_plru_tree_nodes[5].next_node_is_left  = 1; \
                next_plru_tree_nodes[11].next_node_is_right = 1; \
                next_plru_tree_nodes[11].next_node_is_left  = 0; \
            end \
            4'hA: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 0; \
                next_plru_tree_nodes[2].next_node_is_left  = 1; \
                next_plru_tree_nodes[5].next_node_is_right = 1; \
                next_plru_tree_nodes[5].next_node_is_left  = 0; \
                next_plru_tree_nodes[12].next_node_is_right = 0; \
                next_plru_tree_nodes[12].next_node_is_left  = 1; \
            end \
            4'hB: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 0; \
                next_plru_tree_nodes[2].next_node_is_left  = 1; \
                next_plru_tree_nodes[5].next_node_is_right = 1; \
                next_plru_tree_nodes[5].next_node_is_left  = 0; \
                next_plru_tree_nodes[12].next_node_is_right = 1; \
                next_plru_tree_nodes[12].next_node_is_left  = 0; \
            end \
            4'hC: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 1; \
                next_plru_tree_nodes[2].next_node_is_left  = 0; \
                next_plru_tree_nodes[6].next_node_is_right = 0; \
                next_plru_tree_nodes[6].next_node_is_left  = 1; \
                next_plru_tree_nodes[13].next_node_is_right = 0; \
                next_plru_tree_nodes[13].next_node_is_left  = 1; \
            end \
            4'hD: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 1; \
                next_plru_tree_nodes[2].next_node_is_left  = 0; \
                next_plru_tree_nodes[6].next_node_is_right = 0; \
                next_plru_tree_nodes[6].next_node_is_left  = 1; \
                next_plru_tree_nodes[13].next_node_is_right = 1; \
                next_plru_tree_nodes[13].next_node_is_left  = 0; \
            end \
            4'hE: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 1; \
                next_plru_tree_nodes[2].next_node_is_left  = 0; \
                next_plru_tree_nodes[6].next_node_is_right = 1; \
                next_plru_tree_nodes[6].next_node_is_left  = 0; \
                next_plru_tree_nodes[14].next_node_is_right = 0; \
                next_plru_tree_nodes[14].next_node_is_left  = 1; \
            end \
            4'hF: begin \
                next_plru_tree_nodes[0].next_node_is_right = 1; \
                next_plru_tree_nodes[0].next_node_is_left  = 0; \
                next_plru_tree_nodes[2].next_node_is_right = 1; \
                next_plru_tree_nodes[2].next_node_is_left  = 0; \
                next_plru_tree_nodes[6].next_node_is_right = 1; \
                next_plru_tree_nodes[6].next_node_is_left  = 0; \
                next_plru_tree_nodes[14].next_node_is_right = 1; \
                next_plru_tree_nodes[14].next_node_is_left  = 0; \
            end \
            default: begin \
                next_plru_tree_nodes = plru_tree_nodes; \
            end \
        endcase \

`define SEARCH_EVICTED(EVICTED_CL) \
    begin \
        logic [$clog2(WAYS_NUM)-1:0] current_node; \
        integer depth; \
        depth = $clog2(WAYS_NUM); \
        current_node = 0; \
        for (integer i = 0; i < depth-1; i++) begin \
            if (plru_tree_nodes[current_node].next_node_is_left) begin \
                current_node = (current_node << 1) + 2; \
            end else begin \
                current_node = (current_node << 1) + 1; \
            end \
        end \
        case (current_node) \
            4'h7: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h1 : 4'h0; \
            4'h8: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h3 : 4'h2; \
            4'h9: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h5 : 4'h4; \
            4'hA: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h7 : 4'h6; \
            4'hB: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'h9 : 4'h8; \
            4'hC: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'hB : 4'hA; \
            4'hD: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'hD : 4'hC; \
            4'hE: EVICTED_CL = (plru_tree_nodes[current_node].next_node_is_left) ? 4'hF : 4'hE; \
            default: EVICTED_CL = current_node; \
        endcase \
    end

`endif // PLRU_MACROS_VH



